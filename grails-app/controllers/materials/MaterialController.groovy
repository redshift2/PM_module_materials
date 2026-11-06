package materials

import grails.plugin.springsecurity.annotation.Secured
import grails.gorm.transactions.Transactional
import groovy.json.JsonOutput
import groovy.json.JsonSlurper

@Secured(['ROLE_PLM_USER', 'ROLE_ADMIN'])
class MaterialController {
    MaterialService materialService
    def springSecurityService

    /**
     * Resolve the optional Server Administration event service at runtime,
     * avoiding a compile-time dependency between the two Grails plugins.
     * A failure to audit is logged rather than hiding a successful material edit.
     */
    private void reportMaterialEvent(String type, Material material, Map details = [:]) {
        try {
            def context = grailsApplication.mainContext
            if (!context.containsBean('serverEventService')) {
                log.warn("Materials event {} not recorded: Server Administration is not installed", type)
                return
            }
            String actor = springSecurityService?.currentUser?.username?.toString()
            context.getBean('serverEventService').record(
                type, 'materials', 'Material', material.id,
                actor, "${type}: ${material.name}", details
            )
        } catch (Exception ex) {
            log.error("Failed to report Materials event ${type} for material ${material?.id}", ex)
        }
    }

    /** Read-only lookup in the existing PLM domain. No material-side part storage. */
    private List<Map> findPlmPartsUsingMaterial(String materialName) {
        if (!materialName?.trim()) return []
        // Resolve at runtime so the Materials plugin does not need a compile-time
        // dependency on the PLM plugin's domain classes.
        Class partClass = grailsApplication.domainClasses.find {
            it.clazz.name == 'plm.PlmFreeCadPart'
        }?.clazz
        if (!partClass) return []

        def security = grailsApplication.mainContext.getBean('plmFreeCadSecurityService')
        def currentUser = springSecurityService.currentUser
        def matches = partClass.executeQuery('''
            from PlmFreeCadPart p
            where p.active = true
              and lower(trim(p.material)) = :materialName
            order by p.label asc
        ''', [materialName: materialName.trim().toLowerCase(java.util.Locale.ROOT)])

        matches.findAll { part ->
            security.canDownloadFile(part, currentUser)
        }.collect { part ->
            [id: part.id,
             name: part.label ?: part.originalName ?: 'Unnamed part',
             cadVersion: "${part.majorVersion ?: 1}.${part.minorVersion == null ? 0 : part.minorVersion}",
             lifecycleState: part.lifecycleState?.toString() ?: '—']
        }
    }

    def index() {
        Long categoryId = params.long('categoryId')
        int max = Math.min(Math.max(params.int('max') ?: 25, 1), 100)
        int offset = Math.max(params.int('offset') ?: 0, 0)
        def results = materialService.search([categoryId:categoryId, q:params.q, max:max, offset:offset])
        [roots:materialService.rootCategories(), results:results, query:params.q ?: '',
         selectedId:categoryId, max:max, offset:offset,
         categories:MaterialCategory.findAllByActive(true,[sort:'name']),
         isAdmin:request.isUserInRole('ROLE_ADMIN'), activeRootId:findRootId(results.category)]
    }

    private Long findRootId(MaterialCategory c) {
        Set<Long> visited = [] as Set
        while (c?.parent && visited.add(c.id)) c = c.parent
        c?.id
    }

    def show(Long id) {
        Material material = Material.get(id)
        if (!material || !material.active) { response.sendError(404); return }
        [material:material, details:materialService.details(material),
         plmParts:findPlmPartsUsingMaterial(material.name),
         isAdmin:request.isUserInRole('ROLE_ADMIN')]
    }

    @Secured(['ROLE_ADMIN'])
    def create() {
        [material:new Material(), categories:MaterialCategory.findAllByActive(true,[sort:'name']),
         propertiesText:'{}', editing:false]
    }

    @Secured(['ROLE_ADMIN'])
    def edit(Long id) {
        Material m = Material.get(id)
        if (!m) { response.sendError(404); return }
        [material:m, categories:MaterialCategory.findAllByActive(true,[sort:'name']),
         propertiesText:groovy.json.JsonOutput.prettyPrint(m.propertiesJson ?: '{}'), editing:true]
    }

    @Secured(['ROLE_ADMIN'])
    @Transactional
    def save() {
        Material m = new Material()
        if (!populate(m)) { render(view:'create',model:[material:m,categories:MaterialCategory.findAllByActive(true,[sort:'name']),propertiesText:params.propertiesJson ?: '{}',editing:false]);return }
        if (!m.save(flush:true)) { flash.error=m.errors.allErrors.collect { it.defaultMessage }.join('; ');render(view:'create',model:[material:m,categories:MaterialCategory.findAllByActive(true,[sort:'name']),propertiesText:params.propertiesJson ?: '{}',editing:false]);return }
        reportMaterialEvent('MATERIAL_ADD', m, [
            name: m.name, categoryId: m.category?.id,
            categoryName: m.category?.name, densityKgM3: m.densityKgM3,
            active: m.active
        ])
        flash.message='Material created.'
        response.sendRedirect('/material/show/' + m.id.toString())
    }

    @Secured(['ROLE_ADMIN'])
    @Transactional
    def update(Long id) {
        Material m = Material.get(id)
        if (!m) { response.sendError(404);return }
        Map previous = [
            name: m.name, categoryId: m.category?.id,
            categoryName: m.category?.name, densityKgM3: m.densityKgM3,
            active: m.active
        ]
        if (!populate(m)) { render(view:'edit',model:[material:m,categories:MaterialCategory.findAllByActive(true,[sort:'name']),propertiesText:params.propertiesJson ?: '{}',editing:true]);return }
        if (!m.save(flush:true)) { flash.error=m.errors.allErrors.collect { it.defaultMessage }.join('; ');render(view:'edit',model:[material:m,categories:MaterialCategory.findAllByActive(true,[sort:'name']),propertiesText:params.propertiesJson ?: '{}',editing:true]);return }
        reportMaterialEvent('MATERIAL_EDIT', m, [
            previous: previous,
            current: [name: m.name, categoryId: m.category?.id,
                      categoryName: m.category?.name, densityKgM3: m.densityKgM3,
                      active: m.active]
        ])
        flash.message='Material updated.'
        response.sendRedirect('/material/show/' + m.id.toString())
    }

    private boolean populate(Material m) {
        m.name=params.name?.trim()
        m.generalDescription=params.generalDescription?.trim()
        m.category=MaterialCategory.get(params.long('categoryId'))
        m.active=params.active == 'on'
        try {
            m.densityKgM3=params.densityKgM3?.trim() ? new BigDecimal(params.densityKgM3.trim()) : null
            def properties=new JsonSlurper().parseText(params.propertiesJson?.trim() ?: '{}')
            if (!(properties instanceof Map)) throw new IllegalArgumentException('Properties must be a JSON object')
            m.propertiesJson=JsonOutput.toJson(properties)
        } catch (Exception e) { flash.error='Invalid density or properties JSON: '+e.message;return false }
        if (!m.name || !m.category) { flash.error='Name and category are required.';return false }
        true
    }

    @Secured(['ROLE_ADMIN'])
    @Transactional
    def delete(Long id) {
        Material m=Material.get(id)
        if (!m) { response.sendError(404);return }
        m.active=false
        m.save(flush:true,failOnError:true)
        reportMaterialEvent('MATERIAL_DELETE', m, [
            name: m.name, categoryId: m.category?.id,
            categoryName: m.category?.name, deactivated: true
        ])
        flash.message='Material deactivated.'
        response.sendRedirect('/material/index')
    }

    @Secured(['ROLE_ADMIN'])
    def categories() {
        [categories:MaterialCategory.list(sort:'name'), roots:materialService.rootCategories()]
    }

    @Secured(['ROLE_ADMIN'])
    @Transactional
    def saveCategory() {
        String name=params.name?.trim()
        MaterialCategory parent=params.long('parentId') ? MaterialCategory.get(params.long('parentId')) : null
        if (!name || name.length()>120) { flash.error='Category name is required (max 120 characters).';response.sendRedirect('/material/categories');return }
        MaterialCategory c=new MaterialCategory(name:name,description:params.description?.trim(),parent:parent,active:true,displayOrder:params.int('displayOrder') ?: 0)
        if (!c.save(flush:true)) flash.error=c.errors.allErrors.collect {it.defaultMessage}.join('; ')
        else flash.message='Category created.'
        response.sendRedirect('/material/categories')
    }

    @Secured(['ROLE_ADMIN'])
    @Transactional
    def updateCategory(Long id) {
        MaterialCategory c=MaterialCategory.get(id)
        if (!c) { response.sendError(404);return }
        MaterialCategory parent=params.long('parentId') ? MaterialCategory.get(params.long('parentId')) : null
        if (parent?.id==c.id || (parent && materialService.descendants(c)*.id.contains(parent.id))) {
            flash.error='A category cannot be its own descendant.';response.sendRedirect('/material/categories');return
        }
        c.name=params.name?.trim()
        c.description=params.description?.trim()
        c.parent=parent
        c.displayOrder=params.int('displayOrder') ?: 0
        c.active=params.active == 'on'
        if (!c.save(flush:true)) flash.error=c.errors.allErrors.collect {it.defaultMessage}.join('; ')
        else flash.message='Category updated.'
        response.sendRedirect('/material/categories')
    }
}