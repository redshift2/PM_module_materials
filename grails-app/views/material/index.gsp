<div class="pm-shell" data-pm-theme="dark">
<g:render template="/shared/pmShellStyles"/>
<g:render template="/shared/pmShellSidebar"/>
<div class="pm-main">
<g:render template="/shared/pmShellHeader" model="[moduleTitle:'Materials Library']"/>
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
<div class="mat-page"><div class="mat-top"><h1>Materials Library</h1><div class="mat-actions"><g:if test="${isAdmin}"><g:link action="create" class="mat-btn mat-btn-primary">+ Add Material</g:link><g:link action="categories" class="mat-btn">Manage Categories</g:link></g:if></div></div><g:if test="${flash.error}"><div class="mat-error">${flash.error.encodeAsHTML()}</div></g:if><g:if test="${flash.message}"><div class="mat-success">${flash.message.encodeAsHTML()}</div></g:if><nav class="mat-tabs"><g:link action="index" params="${[q:query]}" class="${!selectedId ? 'active' : ''}">All Materials</g:link><g:each in="${roots}" var="root"><g:link action="index" params="${[categoryId:root.id,q:query]}" class="${activeRootId == root.id ? 'active' : ''}">${root.name.encodeAsHTML()}</g:link></g:each></nav>
<section class="mat-card"><div class="mat-card-head"><div class="mat-top" style="margin:0"><h2>${results.category?.name?.encodeAsHTML() ?: 'All Materials'}</h2><span class="mat-count">${results.total} materials</span></div></div><div class="mat-card-body">
<g:if test="${results.category}"><div class="mat-subcats"><g:each in="${materials.MaterialCategory.findAllByParentAndActive(results.category,true,[sort:'displayOrder'])}" var="child"><g:link action="index" params="${[categoryId:child.id,q:query]}" class="mat-btn">${child.name.encodeAsHTML()}</g:link></g:each></div></g:if>
<g:form action="index" method="GET" class="mat-search"><g:if test="${selectedId}"><input type="hidden" name="categoryId" value="${selectedId}"/></g:if><input name="q" value="${query.encodeAsHTML()}" placeholder="Search material names and descriptions" aria-label="Search materials"/><button type="submit" class="mat-btn mat-btn-primary">Search</button><g:link action="index" params="${selectedId ? [categoryId:selectedId] : [:]}" class="mat-btn">Clear</g:link></g:form></div>
<div class="mat-table-wrap"><table><thead><tr><th>Material</th><th>General Description</th><th>Density (kg/m³)</th><th>Young's Modulus</th><th>Poisson's Ratio</th><th>Actions</th></tr></thead><tbody>
<g:each in="${results.items}" var="m"><g:set var="props" value="${new groovy.json.JsonSlurper().parseText(m.propertiesJson ?: '{}')}"/><tr><td><g:link action="show" id="${m.id}">${m.name.encodeAsHTML()}</g:link></td><td class="mat-description">${m.generalDescription?.encodeAsHTML() ?: '—'}</td><td>${m.densityKgM3 ?: '—'}</td><td>${props.get('Models.LinearElastic.YoungsModulus')?.toString()?.encodeAsHTML() ?: '—'}</td><td>${props.get('Models.LinearElastic.PoissonRatio')?.toString()?.encodeAsHTML() ?: '—'}</td><td><div class="mat-row-actions"><g:link action="show" id="${m.id}" class="mat-btn">View</g:link><g:if test="${isAdmin}"><g:link action="edit" id="${m.id}" class="mat-btn">Edit</g:link></g:if></div></td></tr></g:each>
<g:if test="${!results.items}"><tr><td colspan="6" class="mat-muted">No materials found. <g:if test="${!roots}">The initial catalogue has not been seeded; check the server startup log for MATERIALS messages.</g:if></td></tr></g:if></tbody></table></div><div class="mat-card-body mat-pager"><span class="mat-muted">${results.total} matching materials</span><g:if test="${offset > 0}"><g:link action="index" params="${[categoryId:selectedId,q:query,offset:Math.max(0,offset-max),max:max]}" class="mat-btn">← Previous</g:link></g:if><g:if test="${offset + max < results.total}"><g:link action="index" params="${[categoryId:selectedId,q:query,offset:offset+max,max:max]}" class="mat-btn">Next →</g:link></g:if></div></section></div><script>
(function () {
  // Calculate actual stacked heights, including wrapped tabs on smaller screens.
  function positionStickyParts() {
    var page=document.querySelector('.mat-page');
    if (!page) return;
    var header=page.querySelector(':scope > .mat-top');
    var tabs=page.querySelector(':scope > .mat-tabs');
    var title=page.querySelector('.mat-card-head');
    var search=page.querySelector('.mat-card > .mat-card-body');
    if (!(header && tabs && title && search)) return;
    var root=document.documentElement;
    var a=header.offsetHeight;
    page.style.paddingTop=a+'px';
    var b=a+tabs.offsetHeight;
    var c=b+title.offsetHeight;
    var d=c+search.offsetHeight;
    root.style.setProperty('--mat-header-bottom',a+'px');
    root.style.setProperty('--mat-tabs-bottom',b+'px');
    root.style.setProperty('--mat-card-head-bottom',c+'px');
    root.style.setProperty('--mat-search-bottom',d+'px');
  }
  document.addEventListener('DOMContentLoaded',function(){
    positionStickyParts();
    window.addEventListener('resize',positionStickyParts);
    if (window.ResizeObserver) {
      var observer=new ResizeObserver(positionStickyParts);
      ['.mat-page > .mat-top','.mat-page > .mat-tabs','.mat-card-head','.mat-card > .mat-card-body'].forEach(function(sel){
        var el=document.querySelector(sel);if(el)observer.observe(el);
      });
    }
  });
})();
</script>
</main>
</div>
<g:render template="/shared/pmShellScript"/>
</div>
