package materials

class Material {
    String name
    String generalDescription
    MaterialCategory category
    BigDecimal densityKgM3
    String propertiesJson = '{}'
    String sourceFile
    Boolean active = true
    Date dateCreated
    Date lastUpdated

    static constraints = {
        name blank: false, maxSize: 255
        generalDescription nullable: true
        category nullable: false
        densityKgM3 nullable: true, min: 0.0G
        propertiesJson blank: false
        sourceFile nullable: true, maxSize: 500, unique: true
    }
    static mapping = {
        table 'pm_material'
        generalDescription type: 'text'
        propertiesJson type: 'text'
        category index: 'pm_material_category_idx'
    }
}
