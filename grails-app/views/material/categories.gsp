<div class="pm-shell" data-pm-theme="dark">
<g:render template="/shared/pmShellStyles"/>
<g:render template="/shared/pmShellSidebar"/>
<div class="pm-main">
<g:render template="/shared/pmShellHeader" model="[moduleTitle:'Materials — Categories']"/>
<main class="pm-content">
<style>
/* Material module-specific styling; shared shell owns the blue header. */
.pm-shell .mat-page {max-width:none; margin:0; padding:12px 10px 28px; color:var(--pm-text); font:14px/1.5 system-ui,-apple-system,"Segoe UI",sans-serif;}
.pm-shell .mat-page * {box-sizing:border-box;}
.pm-shell .mat-page a {color:#85c2ff;text-decoration:none;}
.pm-shell .mat-page a:hover {text-decoration:underline;}
.pm-shell .mat-page .mat-top {position:static!important; background:transparent!important; padding:0!important; margin:0 0 18px!important; min-height:0!important; display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;}
.pm-shell .mat-page .mat-top h1 {font-size:24px; color:var(--pm-text);margin:0;}
.pm-shell .mat-page h1,.pm-shell .mat-page h2,.pm-shell .mat-page label {color:var(--pm-text)!important;}
.pm-shell .mat-page .mat-card {background:var(--pm-surface)!important;border:1px solid var(--pm-border)!important;border-radius:7px;margin:16px 0;overflow:hidden;box-shadow:none!important;}
.pm-shell .mat-page .mat-card-head {background:var(--pm-sidebar)!important;border-bottom:1px solid var(--pm-border)!important;padding:12px 16px;}
.pm-shell .mat-page .mat-card-body {padding:16px;}
.pm-shell .mat-page .mat-table-wrap {overflow-x:auto;}
.pm-shell .mat-page table {width:100%;border-collapse:collapse;}
.pm-shell .mat-page th {background:var(--pm-sidebar)!important;color:var(--pm-text)!important;border-bottom:1px solid var(--pm-border)!important;padding:11px 13px;}
.pm-shell .mat-page td {background:transparent!important;color:var(--pm-text)!important;border-bottom:1px solid var(--pm-border)!important;padding:11px 13px;}
.pm-shell .mat-page .mat-btn,.pm-shell .mat-page button {background:var(--pm-surface)!important;color:var(--pm-text)!important;border:1px solid var(--pm-border)!important;border-radius:5px;padding:8px 12px;cursor:pointer;}
.pm-shell .mat-page .mat-btn-primary,.pm-shell .mat-page button[type=submit] {background:var(--pm-blue)!important;color:#fff!important;border-color:var(--pm-blue)!important;}
.pm-shell .mat-page input,.pm-shell .mat-page textarea,.pm-shell .mat-page select {background:var(--pm-bg)!important;color:var(--pm-text)!important;border:1px solid var(--pm-border)!important;border-radius:4px;padding:8px;}
.pm-shell .mat-page .mat-tabs {background:transparent!important;position:static!important;}
.pm-shell .mat-page .mat-sticky {top:60px!important;}
.pm-shell[data-pm-theme=light] .mat-page a {color:#175e9a;}
@media(max-width:700px){.pm-shell .mat-page{padding:8px 0 20px;}.pm-shell .mat-page .mat-card-body{padding:10px;}}
</style>
<div class="mat-page"><div class="mat-top"><h1>Manage Categories</h1><g:link action="index" class="mat-btn">← Materials Library</g:link></div><g:if test="${flash.error}"><div class="mat-error">${flash.error.encodeAsHTML()}</div></g:if><g:if test="${flash.message}"><div class="mat-success">${flash.message.encodeAsHTML()}</div></g:if><section class="mat-card"><div class="mat-card-head"><h2>Add Category / Subcategory</h2></div><div class="mat-card-body"><g:form action="saveCategory" method="POST"><div class="mat-field"><label>Category Name</label><input name="name" required maxlength="120"/></div><div class="mat-field"><label>Description</label><input name="description" maxlength="2000"/></div><div class="mat-field"><label>Parent Category (optional)</label><select name="parentId"><option value="">Top-level tab</option><g:each in="${categories.findAll { it.active }}" var="c"><option value="${c.id}">${c.name.encodeAsHTML()}</option></g:each></select></div><div class="mat-field"><label>Display Order</label><input name="displayOrder" type="number" min="0" value="0"/></div><button class="mat-btn mat-btn-primary">Add Category</button></g:form></div></section><section class="mat-card"><div class="mat-card-head"><h2>Existing Categories</h2></div><div class="mat-table-wrap"><table><thead><tr><th>Category</th><th>Parent</th><th>Order</th><th>Active</th><th>Update</th></tr></thead><tbody><g:each in="${categories}" var="c"><tr><g:form action="updateCategory" id="${c.id}" method="POST"><td><input name="name" value="${c.name.encodeAsHTML()}" required maxlength="120"/><input name="description" value="${c.description?.encodeAsHTML() ?: ''}" placeholder="Description" maxlength="2000"/></td><td><select name="parentId"><option value="">Top-level tab</option><g:each in="${categories.findAll { it.id != c.id && it.active }}" var="p"><option value="${p.id}" ${c.parent?.id == p.id ? 'selected="selected"' : ''}>${p.name.encodeAsHTML()}</option></g:each></select></td><td><input name="displayOrder" type="number" min="0" value="${c.displayOrder}" style="width:75px"/></td><td><input name="active" type="checkbox" ${c.active ? 'checked="checked"' : ''}/></td><td><button class="mat-btn mat-btn-primary">Save</button></td></g:form></tr></g:each></tbody></table></div></section></div><script>
(function () {
  function adjustMaterialHeaderSpacing() {
    var page = document.querySelector('.mat-page');
    if (!page) return;
    var header = page.querySelector(':scope > .mat-top');
    if (header) page.style.setProperty('padding-top', header.offsetHeight + 'px', 'important');
  }
  document.addEventListener('DOMContentLoaded', function () {
    adjustMaterialHeaderSpacing();
    window.addEventListener('resize', adjustMaterialHeaderSpacing);
    if (window.ResizeObserver) {
      var header = document.querySelector('.mat-page > .mat-top');
      if (header) new ResizeObserver(adjustMaterialHeaderSpacing).observe(header);
    }
  });
})();
</script>
</main>
</div>
<g:render template="/shared/pmShellScript"/>
</div>
