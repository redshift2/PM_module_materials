package materials

import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.event.EventListener

/** Seed the bundled catalogue once after the database and Grails services are ready. */
class MaterialStartupService {
    MaterialSeedService materialSeedService

    @EventListener(ApplicationReadyEvent)
    void initializeMaterials() {
        try {
            Map result = materialSeedService.seed()
            log.info("MATERIALS: Catalogue ready; added ${result.added}, total ${result.total}")
        } catch (Exception ex) {
            log.error('MATERIALS: Initial catalogue seed failed', ex)
        }
    }
}
