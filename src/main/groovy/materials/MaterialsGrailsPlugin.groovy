package materials

import grails.plugins.Plugin

class MaterialsGrailsPlugin extends Plugin {
    def grailsVersion = "7.0.0 > *"
    def title = "Materials Library"
    def author = "Parts Manager"
    def description = "Material catalogues and physical properties"
    def profiles = ['web']
    Closure doWithSpring() { { -> } }
    void doWithApplicationContext() { }
}
