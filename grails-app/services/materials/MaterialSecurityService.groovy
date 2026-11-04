package materials

import jakarta.annotation.PostConstruct
import org.codehaus.groovy.runtime.MethodClosure
import taack.app.TaackApp
import taack.app.TaackAppRegisterService

class MaterialSecurityService {
    static lazyInit = false

    @PostConstruct
    void init() {
        log.info('MATERIALS: Starting application registration')
        def resource = this.class.getResourceAsStream('/materials/materials.svg')
        if (resource == null) {
            log.error('MATERIALS: materials.svg resource not found')
            return
        }
        String svg = resource.withCloseable {
            new String(it.readAllBytes(), 'UTF-8')
        }
        TaackAppRegisterService.register(
            new TaackApp(MaterialController.&index as MethodClosure, svg)
        )
        log.info('MATERIALS: Application registered successfully')
    }
}
