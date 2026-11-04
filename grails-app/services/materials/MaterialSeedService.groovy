package materials

import grails.gorm.transactions.Transactional
import groovy.json.JsonSlurper

/** Explicit one-time bootstrap, NOT an end-user CSV import facility. */
@Transactional
class MaterialSeedService {
    static final List<String> ROOTS = ['Metals','Plastics','Fluids','Glass','Concrete','Wood','Ceramics','Composites','Other']

    Map seed() {
        Map<String, MaterialCategory> categories = [:]
        ROOTS.eachWithIndex { String name, int i ->
            MaterialCategory c = MaterialCategory.findByNameAndParentIsNull(name)
            if (!c) c = new MaterialCategory(name:name,displayOrder:i,active:true).save(failOnError:true)
            categories[name] = c
        }
        def stream = this.class.classLoader.getResourceAsStream('materials/starter-materials.json')
        if (!stream) throw new IllegalStateException('Missing starter-materials.json')
        def records
        stream.withCloseable { records = new JsonSlurper().parse(it, 'UTF-8') }
        int added = 0
        records.each { item ->
            if (!Material.findBySourceFile(item.sourceFile.toString())) {
                new Material(name:item.name.toString(), generalDescription:item.generalDescription?.toString(),
                    category:categories[item.category.toString()] ?: categories['Other'],
                    densityKgM3:item.densityKgM3 == null ? null : new BigDecimal(item.densityKgM3.toString()),
                    propertiesJson:groovy.json.JsonOutput.toJson(item.properties),
                    sourceFile:item.sourceFile.toString(), active:true).save(failOnError:true)
                added++
            }
        }
        [added:added, total:Material.count()]
    }
}
