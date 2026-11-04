package materials

import grails.gorm.transactions.Transactional
import groovy.json.JsonSlurper

@Transactional(readOnly = true)
class MaterialService {
    List<MaterialCategory> rootCategories() {
        MaterialCategory.findAllByParentIsNullAndActive(true, [sort:'displayOrder', order:'asc'])
    }

    List<MaterialCategory> descendants(MaterialCategory category) {
        List<MaterialCategory> result = []
        Set<Long> seen = [] as Set
        List<MaterialCategory> pending = [category]
        while (pending) {
            MaterialCategory current = pending.remove(0)
            if (current?.id != null && seen.add(current.id)) {
                result << current
                pending.addAll(MaterialCategory.findAllByParentAndActive(current, true))
            }
        }
        result
    }

    Map search(Map params) {
        Long categoryId = params.categoryId ? params.categoryId.toString().toLong() : null
        MaterialCategory category = categoryId ? MaterialCategory.get(categoryId) : null
        if (categoryId && (!category || !category.active)) return [items: [], total: 0, category: null]
        List<Long> ids = category ? descendants(category)*.id : []
        String q = (params.q ?: '').toString().trim().toLowerCase()
        int max = Math.min(Math.max((params.max ?: 25).toString().toInteger(), 1), 100)
        int offset = Math.max((params.offset ?: 0).toString().toInteger(), 0)
        def result = Material.createCriteria().list(max: max, offset: offset) {
            eq('active', true)
            if (category) { 'in'('category.id', ids) }
            if (q) {
                or {
                    ilike('name', "%${q}%")
                    ilike('generalDescription', "%${q}%")
                }
            }
            order('name', 'asc')
        }
        [items: result.toList(), total: result.totalCount, category: category]
    }

    Map details(Material material) {
        [id: material.id, name: material.name, generalDescription: material.generalDescription,
         category: [id:material.category.id, name:material.category.name],
         densityKgM3: material.densityKgM3,
         properties: new JsonSlurper().parseText(material.propertiesJson ?: '{}')]
    }
}
