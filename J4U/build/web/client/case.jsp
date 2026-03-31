<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    String greet=(hour<12)?"Good Morning":(hour<16)?"Good Afternoon":(hour<21)?"Good Evening":"Safe Haven";
    String profileType=(String)session.getAttribute("profileType");
    boolean isAdmin="admin".equalsIgnoreCase(profileType)||"admin_assigned".equalsIgnoreCase(profileType)||"assigned".equalsIgnoreCase(profileType);
    String dashURL=isAdmin?"customerdashboard.jsp":"clientdashboard_manual.jsp";
    String selLawyer=request.getParameter("lawyer_email"), selLawyerName=request.getParameter("lawyer_name");
%>
<!DOCTYPE html>
<html lang="en">
<jsp:include page="components/_head.jsp"><jsp:param name="title" value="Client Portal"/></jsp:include>
<body>
<div class="app-layout">
    <jsp:include page="components/_sidebar.jsp" />
    <main class="main-content">
        <jsp:include page="components/_topbar.jsp"><jsp:param name="title" value="Client"/><jsp:param name="subtitle" value="Portal"/></jsp:include>
        <div class="p-5">
            <form action="../ProcessCaseRequestServlet" method="post" enctype="multipart/form-data" style="max-width:900px;">
                <% if(selLawyer!=null){ %>
                    <div class="alert alert-gold border-0 d-flex align-items-center gap-3 mb-4">
                        <i class="ph-fill ph-star h3 mb-0"></i>
                        <div><h6 class="mb-0">Direct Request to <%=selLawyerName%></h6><p class="small mb-0">This case will be prioritized for chosen counsel.</p></div>
                        <input type="hidden" name="selected_lawyer_email" value="<%=selLawyer%>">
                    </div>
                <% } %>
                <div class="panel p-5 mb-4">
                    <h4 class="panel-head border-bottom-0 p-0 mb-4"><i class="ph-duotone ph-file-text panel-icon"></i> Case Information</h4>
                    <div class="row g-4">
                        <div class="col-12"><label class="form-label small fw-bold">Case Title</label><input type="text" name="title" class="form-control p-3" placeholder="Brief subject of the legal matter" required></div>
                        <div class="col-12"><label class="form-label small fw-bold">Detailed Matter</label><textarea name="description" class="form-control p-3" rows="4" placeholder="Describe the incident, names involved, and desired outcome..." required></textarea></div>
                        <div class="col-md-6"><label class="form-label small fw-bold">Legal Category</label><select name="category" class="form-select p-3" required><option value="" disabled selected>Select practice area</option><option>Civil Litigation</option><option>Criminal Defense</option><option>Family & Divorce</option><option>Property & Real Estate</option><option>Corporate Law</option><option>Other</option></select></div>
                        <div class="col-md-6"><label class="form-label small fw-bold">Urgency</label><select name="urgency" class="form-select p-3" required><option>Standard</option><option>High</option><option>Critical</option></select></div>
                    </div>
                </div>
                <div class="panel p-5 mb-4">
                    <h4 class="panel-head border-bottom-0 p-0 mb-4"><i class="ph-duotone ph-paperclip panel-icon"></i> Evidence & Processing</h4>
                    <div class="row g-4">
                        <div class="col-md-6"><label class="form-label small fw-bold">Supporting Documents</label><input type="file" name="documents" class="form-control p-3" accept=".pdf,.jpg,.png" required></div>
                        <div class="col-md-6"><label class="form-label small fw-bold">Platform Retainer</label><input type="text" class="form-control p-3 bg-light" value="â‚¹ 500.00" readonly></div>
                        <div class="col-md-12"><label class="form-label small fw-bold">Transaction Reference</label><input type="text" name="transactionId" class="form-control p-3" placeholder="Enter UPI / Bank Trace ID" required></div>
                    </div>
                </div>
                <div class="d-flex align-items-center gap-3 mb-5 mt-4">
                    <input type="checkbox" id="terms" required class="form-check-input"><label for="terms" class="small text-muted">I certify that all provided details are accurate and authorize legal processing.</label>
                </div>
                <div class="row g-3">
                    <div class="col-md-8"><button type="submit" class="btn btn-dark w-100 p-3 rounded-pill fw-bold">Encrypt & Submit Legal Case <i class="ph ph-arrow-right ms-2"></i></button></div>
                    <div class="col-md-4"><a href="<%=dashURL%>" class="btn btn-outline-dark w-100 p-3 rounded-pill fw-bold">Discard</a></div>
                </div>
            </form>
        </div>
    </main>
</div>
</body>
</html>
