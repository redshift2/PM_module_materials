package materials

class MaterialCategory {
    String name
    String description
    MaterialCategory parent
    Integer displayOrder = 0
    Boolean active = true
    Date dateCreated
    Date lastUpdated

    static constraints = {
        name blank: false, maxSize: 120, unique: 'parent'
        description nullable: true, maxSize: 2000
        parent nullable: true, validator: { val, obj -> val == null || val.id != obj.id }
        displayOrder min: 0
    }
    static mapping = {
        table 'pm_material_category'
        description type: 'text'
        parent index: 'pm_material_category_parent_idx'
    }
}
