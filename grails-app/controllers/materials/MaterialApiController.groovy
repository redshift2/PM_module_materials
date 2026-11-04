package materials

import grails.converters.JSON
import grails.plugin.springsecurity.annotation.Secured

@Secured(['ROLE_PLM_USER', 'ROLE_ADMIN'])
class MaterialApiController {
    MaterialService materialService

    def categories() {
        def categories = MaterialCategory.findAllByActive(true, [sort:'displayOrder',order:'asc'])
        render([success:true, categories:categories.collect {
            [id:it.id, name:it.name, description:it.description, parentId:it.parent?.id,
             displayOrder:it.displayOrder]
        }] as JSON)
    }

    def materials() {
        def found = materialService.search([categoryId:params.long('categoryId'),q:params.q,
            max:params.int('max') ?: 25,offset:params.int('offset') ?: 0])
        render([success:true,total:found.total,materials:found.items.collect {
            [id:it.id,name:it.name,generalDescription:it.generalDescription,
             categoryId:it.category.id,densityKgM3:it.densityKgM3]
        }] as JSON)
    }

    def material(Long id) {
        Material m = Material.get(id)
        if (!m || !m.active) { response.sendError(404); return }
        render([success:true, material:materialService.details(m)] as JSON)
    }
}
