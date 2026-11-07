<!doctype html>
<html>
<head>
<meta name="layout" content="main"/>
<title>PLM Workspaces</title>
<style>
/* Self-contained styles: this server does not load Bootstrap on GSP pages. */
body .pmw{font-family:Arial,Helvetica,sans-serif;font-size:14px;line-height:1.5;color:#dce2e8;background:#22272e;padding:0 24px 32px;min-height:100vh}
body .pmw *{box-sizing:border-box}
body .pmw h1{font-size:24px;margin:0;font-weight:600;color:#f4f6f8}
body .pmw h2{font-size:16px;margin:0;color:#f4f6f8}
body .pmw a{color:#7ab8e8;text-decoration:none}
body .pmw a:hover{text-decoration:underline}
body .pmw .pmw-header{display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap;margin:0 -24px 18px;padding:17px 24px;background:#195d8f;min-height:72px}
body .pmw .pmw-actions{display:flex;align-items:center;gap:7px;flex-wrap:wrap}
body .pmw .pmw-card{border:1px solid #454d56;background:#2c323a;border-radius:5px;margin-bottom:16px;overflow:hidden}
body .pmw .pmw-card-title{background:#353d47;padding:11px 14px;border-bottom:1px solid #4b5561}
body .pmw .pmw-card-content{padding:14px}
body .pmw .pmw-btn{display:inline-flex;align-items:center;justify-content:center;gap:6px;padding:7px 11px;border:1px solid #596675;border-radius:4px;background:#414c58;color:#f0f4f8;font:inherit;cursor:pointer;text-decoration:none;min-height:34px}
body .pmw .pmw-header .pmw-btn{background:#285e86;border-color:#8bb4d3;color:#fff}
body .pmw .pmw-header .pmw-btn:hover{background:#377eaf}
body .pmw .pmw-btn:hover{background:#526172;color:#fff;text-decoration:none}
body .pmw .pmw-primary{background:#206ca3;border-color:#337fb7;color:#fff}
body .pmw .pmw-danger{background:#6c3038;border-color:#93444e}
body .pmw .pmw-icon{width:15px;height:15px;display:inline-block;vertical-align:middle;fill:currentColor}
body .pmw input,body .pmw select{background:#20262e;color:#f3f5f8;border:1px solid #647180;border-radius:4px;padding:7px 9px;font:inherit}
body .pmw input{max-width:100%}
body .pmw label{display:block;margin-bottom:4px;color:#dce2e8;font-weight:600}
body .pmw .pmw-form{display:flex;align-items:end;gap:10px;flex-wrap:wrap}
body .pmw .pmw-form>div{min-width:180px;flex:1}
body .pmw .pmw-form input{width:100%}
body .pmw .pmw-table-scroll{overflow-x:auto}
body .pmw table{width:100%;border-collapse:collapse;text-align:left}
body .pmw th{background:#3a434e;color:#f0f4f8;border-bottom:2px solid #65717f;padding:10px 12px;white-space:nowrap}
body .pmw td{border-bottom:1px solid #4c5662;padding:9px 12px;vertical-align:middle}
body .pmw tbody tr:nth-child(even){background:#313943}
body .pmw tbody tr:hover{background:#404d5b}
body .pmw .pmw-row-actions{display:flex;gap:6px;align-items:center;flex-wrap:wrap}
body .pmw .pmw-row-actions form{margin:0}
body .pmw .pmw-error{background:#64333b;color:#fff;padding:10px;border-radius:4px;margin:10px 0}
body .pmw .pmw-muted{color:#b4c0cc}
body .pmw dialog{background:#2d353f;color:#edf2f7;border:1px solid #667483;border-radius:6px;padding:18px;min-width:min(450px,90vw);box-shadow:0 10px 40px #0009}
body .pmw dialog::backdrop{background:#0009}
body .pmw dialog label{margin-top:10px}
body .pmw dialog input,body .pmw dialog select{width:100%}
body .pmw dialog .pmw-actions{margin-top:16px;justify-content:flex-end}
/* Restore the site-wide dark background and eliminate the white surround. */
html,body{margin:0!important;padding:0!important;background:#22272e!important;color:#f0f3f7!important}
/* Pull the opaque blue header over the host layout's tiny page title. */
body .pmw{max-width:none!important;margin:-36px 0 0!important;position:relative;z-index:2}
body .pmw .pmw-header{position:relative;z-index:3}
body .pmw .pmw-success{background:#244b37;color:#d8f5e2;padding:10px;border-radius:4px;margin:10px 0}
</style>
</head>
<body>
<div class="pmw">
  <div class="pmw-header">
    <h1>Workspace Manager</h1>
    <div class="pmw-actions">
      <g:link controller="plm" action="parts" class="pmw-btn">&#8592; PLM Parts</g:link>
      <g:link uri="/" class="pmw-btn">Server Home</g:link>
    </div>
  </div>
  <g:if test="${flash.error}"><div class="pmw-error">${flash.error.encodeAsHTML()}</div></g:if>
  <g:if test="${flash.message}"><div class="pmw-success">${flash.message.encodeAsHTML()}</div></g:if>
  <section class="pmw-card">
    <div class="pmw-card-title"><h2>Create Workspace</h2></div>
    <div class="pmw-card-content">
      <g:form action="create" method="POST" class="pmw-form">
        <div><label for="pmw-create-name">Name</label><input id="pmw-create-name" name="name" required maxlength="160"/></div>
        <div><label for="pmw-create-description">Description</label><input id="pmw-create-description" name="description" maxlength="2000"/></div>
        <button type="submit" class="pmw-btn pmw-primary">+ Create Workspace</button>
      </g:form>
    </div>
  </section>
  <section class="pmw-card">
    <div class="pmw-card-title"><h2>All Accessible Workspaces</h2></div>
    <div class="pmw-table-scroll">
      <table>
        <thead><tr><th>Workspace</th><th>Description</th><th>Owner</th><th>Revision</th><th>Actions</th></tr></thead>
        <tbody>
          <g:each in="${workspaces}" var="w">
            <tr>
              <td><g:link action="show" id="${w.id}">${w.name.encodeAsHTML()}</g:link></td>
              <td>${w.description?.encodeAsHTML() ?: '—'}</td>
              <td>${w.owner?.username?.encodeAsHTML() ?: '—'}</td>
              <td>${w.inventoryRevision}</td>
              <td>
                <div class="pmw-row-actions">
                  <g:link action="show" id="${w.id}" class="pmw-btn" title="Open workspace">Open</g:link>
                  <button type="button" class="pmw-btn" title="Copy workspace" onclick="document.getElementById('pmw-copy-${w.id}').showModal()">
                    <svg class="pmw-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M16 1H4a2 2 0 0 0-2 2v14h2V3h12V1zm3 4H8a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h11a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2zm0 16H8V7h11v14z"/></svg> Copy
                  </button>
                  <g:if test="${w.owner?.id == currentUserId}">
                    <button type="button" class="pmw-btn" title="Edit workspace" onclick="document.getElementById('pmw-edit-${w.id}').showModal()">
                      <svg class="pmw-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a1 1 0 0 0 0-1.41l-2.34-2.34a1 1 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg> Edit
                    </button>
                    <button type="button" class="pmw-btn" title="Share workspace" onclick="document.getElementById('pmw-share-${w.id}').showModal()">
                      <svg class="pmw-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7a3.4 3.4 0 0 0 0-1.4l7.05-4.11a3 3 0 1 0-.94-1.76L7.97 9.54a3 3 0 1 0 0 4.92l7.12 4.16a3 3 0 1 0 2.91-2.54z"/></svg> Share
                    </button>
                    <g:form action="delete" id="${w.id}" method="POST">
                      <button type="submit" class="pmw-btn pmw-danger" title="Delete workspace" onclick="return confirm('Delete this workspace? This cannot be undone.')">
                        <svg class="pmw-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg> Delete
                      </button>
                    </g:form>
                  </g:if>
                </div>
                <dialog id="pmw-copy-${w.id}">
                  <h2>Copy Workspace</h2>
                  <g:form action="duplicate" id="${w.id}" method="POST">
                    <label>New workspace name</label><input name="name" required maxlength="160" placeholder="Workspace copy"/>
                    <div class="pmw-actions"><button type="button" class="pmw-btn" onclick="this.closest('dialog').close()">Cancel</button><button type="submit" class="pmw-btn pmw-primary">Copy</button></div>
                  </g:form>
                </dialog>
                <g:if test="${w.owner?.id == currentUserId}">
                  <dialog id="pmw-edit-${w.id}">
                    <h2>Edit Workspace</h2>
                    <g:form action="updateWorkspace" id="${w.id}" method="POST">
                      <label>Name</label><input name="name" required maxlength="160" value="${w.name?.encodeAsHTML()}"/>
                      <label>Description</label><input name="description" maxlength="2000" value="${w.description?.encodeAsHTML() ?: ''}"/>
                      <div class="pmw-actions"><button type="button" class="pmw-btn" onclick="this.closest('dialog').close()">Cancel</button><button type="submit" class="pmw-btn pmw-primary">Save</button></div>
                    </g:form>
                  </dialog>
                  <dialog id="pmw-share-${w.id}">
                    <h2>Share Workspace</h2>
                    <g:form action="setMember" id="${w.id}" method="POST">
                      <label>Username</label><input name="username" required/>
                      <label>Access</label><select name="role"><option value="VIEWER">Viewer</option><option value="EDITOR">Editor</option></select>
                      <div class="pmw-actions"><button type="button" class="pmw-btn" onclick="this.closest('dialog').close()">Cancel</button><button type="submit" class="pmw-btn pmw-primary">Share</button></div>
                    </g:form>
                    <p class="pmw-muted">To remove access or manage existing members, open this workspace.</p>
                  </dialog>
                </g:if>
              </td>
            </tr>
          </g:each>
          <g:if test="${!workspaces}"><tr><td colspan="5" class="pmw-muted">No accessible workspaces.</td></tr></g:if>
        </tbody>
      </table>
    </div>
  </section>
  <section class="pmw-card" id="pmw-checked-out-parts">
    <div class="pmw-card-title"><h2>My Checked-Out Parts</h2></div>
    <div class="pmw-table-scroll">
      <table>
        <thead><tr><th>Part</th><th>CAD Version</th><th>Checked Out</th><th>Workspaces</th><th>Action</th></tr></thead>
        <tbody>
          <g:each in="${checkedOutParts}" var="row">
            <tr>
              <td><a href="/plm/showPart/${row.part.id}">${(row.part.label ?: row.part.originalName ?: 'Part ' + row.part.id).encodeAsHTML()}</a></td>
              <td>${row.part.majorVersion}.${row.part.minorVersion}</td>
              <td><g:formatDate date="${row.part.checkedOutAt}" format="yyyy-MM-dd HH:mm"/></td>
              <td>
                <g:if test="${row.workspaces}">
                  <g:each in="${row.workspaces}" var="ws" status="idx">
                    <g:if test="${idx > 0}">, </g:if><a href="/workspace/show/${ws.id}">${ws.name.encodeAsHTML()}</a>
                  </g:each>
                </g:if>
                <g:else><span class="pmw-muted">Not in a workspace</span></g:else>
              </td>
              <td>
                <form method="post" action="/workspace/undoCheckOut/${row.part.id}" onsubmit="return confirm('Undo check-out for this part?');">
                  <button type="submit" class="pmw-btn pmw-danger">Undo Check-Out</button>
                </form>
              </td>
            </tr>
          </g:each>
          <g:if test="${!checkedOutParts}"><tr><td colspan="5" class="pmw-muted">You have no checked-out parts.</td></tr></g:if>
        </tbody>
      </table>
    </div>
  </section>
</div>
</body>
</html>