<%@ page contentType="text/xml;charset=ISO-8859-1"%>
<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/xsl" href="api.xsl"?>
<%@ page import="blackboard.platform.plugin.*"%>
<%@ page import="blackboard.platform.security.authentication.SessionStub"%>
<%@ page import="blackboard.platform.security.authentication.BaseAuthenticationModule"%>
<%@ page import="blackboard.platform.security.authentication.BbAuthenticationFailedException"%>
<%@ page import="blackboard.platform.security.authentication.BbSecurityException"%>
<%@ page import="blackboard.persist.course.*"%>
<%@ page import="blackboard.persist.user.*"%>
<%@ page import="blackboard.persist.Id"%>
<%@ page import="blackboard.persist.SearchOperator"%>
<%@ page import="blackboard.data.course.*"%>
<%@ page import="blackboard.data.user.*"%>
<%@ page import="blackboard.ws.context.*"%>
<%@ page import="blackboard.ws.course.*"%>
<%@ page import="blackboard.ws.coursemembership.*"%>
<%@ page import="blackboard.ws.gradebook.*"%>
<%@ page import="blackboard.ws.user.*"%>
<%@ page import="blackboard.ws.util.*"%>
<%@ page import="blackboard.util.Base64Codec"%>
<%@ page import="java.util.*"%>
<%!
public class LocalAuthenticationModule extends BaseAuthenticationModule {
  @Override
  public String authenticate(java.lang.String userName, java.lang.String userToken, SessionStub sessionStub, boolean useChallenge) {
    String authStatus = "";
    Boolean isAuthentic = false;
    
    try {
      authStatus = super.authenticate(userName, Base64Codec.encode(userToken), null, false);
    } catch (BbAuthenticationFailedException fe) {
      authStatus = "API Authentication Exception: " + fe.getMessage();
    } catch (BbSecurityException se) {
      authStatus = "API Security Exception: " + se.getMessage();
    }
    
    return authStatus;
  }
}
%>
<%  
  /* POST params: action, username, auth, id */

  Boolean ok = true;
  String action = "";
  String username = "";
  String auth = "";
  String id = "";
  String output = "<error>Blank</error>";
  String apiReadRole = "API_READ_ROLE";
  int recordCount = 0;
  
  /* check existence of required parameters */
  if (request.getParameter("action") == null 
      || request.getParameter("username") == null 
      || request.getParameter("auth") == null 
      || request.getParameter("id") == null) {
    
    /* redirect to API instructions */
    response.sendRedirect("readme.html");
    
    ok = false;
    output = "<error>Invalid parameters</error>";
  }
  
  if (ok) {
    action = request.getParameter("action").toLowerCase();
    username = request.getParameter("username").toLowerCase();
    auth = request.getParameter("auth");
    id = request.getParameter("id");
    
    output = "<parameters>";
    output += "<action>" + action + "</action>";
    output += "<id>" + id + "</id>";
    output += "</parameters>";
  }
  
  if (ok) {
    try {
      /* get api user details */
      User apiUser = UserDbLoader.Default.getInstance().loadByUserName(username);
      
      String apiUserEncodedStoredPassword = apiUser.getPassword();

      /* get api user system role */
      String apiUserRole = apiUser.getSystemRole().toExternalString().toUpperCase();
      
      /* get array of elements from api user role */
      String[] apiUserRoleElements = apiUserRole.split(":");
      
      if (apiUserRoleElements.length == 2) {      
        String apiUserRoleStub = apiUserRoleElements[1];
        
        if (!apiUserRoleStub.equals(apiReadRole)) {
          ok = false;
          output = "<error>API User role not set</error>";    
        }

        if (ok) {
          
          LocalAuthenticationModule localAuth = new LocalAuthenticationModule();
          
          SessionStub sessionStub = new SessionStub();
          
          String authResults = localAuth.authenticate(username, auth, sessionStub, false);
          
          if (!authResults.toLowerCase().equals(username)) {
            ok = false;
            output = "<error>API User Authorization Fail</error>";    
          }
          
        }
      } else {
        ok = false;
        output = "<error>API User not configured</error>";
      }
    } catch(Exception e) {
      ok = false;
      output = "<error>API User not found</error>";
    }
  }
  
  if (ok) {
    if (action.equals("getuserbyusername")) {
      
      try {
        User user = UserDbLoader.Default.getInstance().loadByUserName(id);

        output += "<user>";
        output += "<batch_id>" + user.getBatchUid() + "</batch_id>";
        output += "<email>" + user.getEmailAddress() + "</email>";
        output += "<first_name>" + user.getGivenName() + "</first_name>";
        output += "<gender>" + user.getGender() + "</gender>";
        output += "<institution_role>" + user.getInstitutionRole().getDisplayName() + "</institution_role>";
        output += "<is_available>" + user.getIsAvailable() + "</is_available>";
        output += "<is_info_public>" + user.getIsInfoPublic() + "</is_info_public>";
        output += "<last_name>" + user.getFamilyName() + "</last_name>";
        output += "<student_id>" + user.getStudentId() + "</student_id>";
        output += "<system_role>" + user.getSystemRole().getDisplayName() + "</system_role>";
        output += "<username>" + user.getUserName() + "</username>";
        output += "</user>";
      } catch(Exception e) {
        ok = false;
        output = "<error>User not found</error>";
      }
      
    } else if (action.equals("getcoursesbyusername")) {
    
      try {
        User user = UserDbLoader.Default.getInstance().loadByUserName(id);
        
        /* get user pk */
        Id userId = user.getId();
        
        /* get user pk string */
        String userIdString = userId.toExternalString();
        
        /* get course memberships */
        ArrayList courseMemberships = CourseMembershipDbLoader.Default.getInstance().loadByUserId(userId);
        
        /* get membership count */
        recordCount = courseMemberships.size();

        output += "<user>";
        output += "<first_name>" + user.getGivenName() + "</first_name>";
        output += "<last_name>" + user.getFamilyName() + "</last_name>";
        output += "<student_id>" + user.getStudentId() + "</student_id>";
        output += "<username>" + user.getUserName() + "</username>";
        output += "<courses count='" + recordCount + "'>";
        
        Iterator cmIterator = courseMemberships.iterator();
        
        while (cmIterator.hasNext()) {
          CourseMembership cm = (CourseMembership) cmIterator.next();
          
          Id courseId = cm.getCourseId();
          String courseIdString = courseId.toExternalString();
          
          Course course = CourseDbLoader.Default.getInstance().loadById(courseId);
        
          output += "<course>";
          output += "<course_id>" + course.getCourseId() + "</course_id>";
          output += "<title>" + course.getTitle() + "</title>";
          output += "</course>";
        }
        
        output += "</courses>";
        output += "</user>";
      } catch(Exception e) {
        ok = false;
        output = "<error>User not found</error>";
      }
      
    } else if (action.equals("getcoursebycourseid")) {
      
      try {
        Course course = CourseDbLoader.Default.getInstance().loadByCourseId(id);

        output += "<course>";
        output += "<batch_id>" + course.getBatchUid() + "</batch_id>";
        output += "<course_id>" + course.getCourseId() + "</course_id>";
        output += "<description>" + course.getDescription() + "</description>";
        output += "<is_available>" + course.getIsAvailable() + "</is_available>";
        output += "<is_child>" + course.isChild() + "</is_child>";
        output += "<is_parent>" + course.isParent() + "</is_parent>";
        output += "<title>" + course.getTitle() + "</title>";
        output += "</course>";
      } catch(Exception e) {
        ok = false;
        output = "<error>Course not found</error>";
      }  
      
    } else if (action.equals("getgradesbycourseid")) {
      
      try {
        /* get course details using supplied id */
        Course course = CourseDbLoader.Default.getInstance().loadByCourseId(id);
        
        /* get course pk */
        Id courseId = course.getId();
        
        /* get course pk string */
        String courseIdString = courseId.toExternalString();
        
        /* get student members of course */
        ArrayList courseMembers = CourseMembershipDbLoader.Default.getInstance().loadByCourseIdAndRole(courseId, CourseMembership.Role.STUDENT);
        
        /* get student count */
        recordCount = courseMembers.size();
        
        /* get gradebook web service factory */
        GradebookWSFactory gbwsf = new GradebookWSFactory();
        
        /* get instance of gradebook web service */
        GradebookWS gbws = gbwsf.getGradebookWS();
        
        /* initialize gradebook ws session */
        Boolean gradebookIsInitialized = false;
        
        Boolean gbIgnore = true;
        
        /* set gradebook column filter */
        ColumnFilter columnFilter = new ColumnFilter();
        columnFilter.setFilterType(blackboard.ws.gradebook.GradebookWSConstants.GET_COLUMN_BY_EXTERNAL_GRADE_FLAG);
        
        /* get gradebook external column */
        ColumnVO[] gradebookColumns = gbws.getGradebookColumns(courseIdString, columnFilter);
        
        /* set gradebook column defaults */
        String gradebookColumnId = "0";
        String gradebookColumnName = "";
        String gradebookColumnAggregationModel = "";
        Boolean gradebookColumnIsExternalGrade = false;
        Boolean gradebookColumnIsVisible = false;
        Boolean gradebookColumnIsScorable = false;
        String gradebookColumnCalculationType = "";
        long gradebookColumnDateDue = 0;
        long gradebookColumnDateCreated = 0;
        long gradebookColumnDateModified = 0;
        double gradebookColumnPossible = 0;
        int gradebookColumnPosition = 0;
        float gradebookColumnWeight = 0;
        
        for (int gradebookColumnIndex=0; gradebookColumnIndex<gradebookColumns.length; gradebookColumnIndex++) {
          ColumnVO gradebookColumn = gradebookColumns[gradebookColumnIndex];
        
          gradebookColumnId = gradebookColumn.getId();
          gradebookColumnName = gradebookColumn.getColumnDisplayName();
          gradebookColumnAggregationModel = gradebookColumn.getAggregationModel();
          gradebookColumnIsExternalGrade = gradebookColumn.isExternalGrade();
          gradebookColumnIsVisible = gradebookColumn.isVisible();
          gradebookColumnIsScorable = gradebookColumn.isScorable();
          gradebookColumnDateDue = gradebookColumn.getDueDate();
          gradebookColumnDateCreated = gradebookColumn.getDateCreated();
          gradebookColumnDateModified = gradebookColumn.getDateModified();
          gradebookColumnPossible = gradebookColumn.getPossible();
          gradebookColumnPosition = gradebookColumn.getPosition();
          gradebookColumnWeight = gradebookColumn.getWeight();
        }
        
        /* set score filter */
        ScoreFilter scoreFilter = new ScoreFilter();
        scoreFilter.setColumnId(gradebookColumnId);
        scoreFilter.setFilterType(blackboard.ws.gradebook.GradebookWSConstants.GET_SCORE_BY_COLUMN_ID);
        
        /* get grades */
        ScoreVO[] grades = gbws.getGrades(courseIdString, scoreFilter);
        
        /* create grade map */
        Map<String, String> memberGrades = new HashMap<String, String>();
        
        for (int scoreIndex=0; scoreIndex<grades.length; scoreIndex++) {
          ScoreVO score = grades[scoreIndex];
          
          String memberId = score.getMemberId();
          String schemaGradeValue = score.getSchemaGradeValue();
          String gradeValue = score.getGrade();
          String grade = "";
          
          if (schemaGradeValue.length() > 0) {
            grade = schemaGradeValue;
          } else if (gradeValue.length() > 0) {
            grade = gradeValue;
          }
          
          /* add grade to map */
          memberGrades.put(memberId, grade);  
        }
        
        output += "<grades>";
        output += "<course_id>" + course.getCourseId() + "</course_id>";
        output += "<title>" + course.getTitle() + "</title>";
        output += "<gradebook>";
        output += "<column>";
        output += "<name>" + gradebookColumnName + "</name>";
        output += "<aggregation_model>" + gradebookColumnAggregationModel + "</aggregation_model>";
        output += "<is_external_grade>" + gradebookColumnIsExternalGrade + "</is_external_grade>";
        output += "<is_visible>" + gradebookColumnIsVisible + "</is_visible>";
        output += "<is_scorable>" + gradebookColumnIsScorable + "</is_scorable>";
        output += "<date>";
        output += "<due>" + gradebookColumnDateDue + "</due>";
        output += "<created>" + gradebookColumnDateCreated + "</created>";
        output += "<modified>" + gradebookColumnDateModified + "</modified>";
        output += "</date>";
        output += "<possible>" + gradebookColumnPossible + "</possible>";
        output += "<position>" + gradebookColumnPosition + "</position>";
        output += "<weight>" + gradebookColumnWeight + "</weight>";
        output += "</column>";
        output += "</gradebook>";
        output += "<students count='" + recordCount + "'>";
        
        Iterator cmIterator = courseMembers.iterator();
        
        while (cmIterator.hasNext()) {
          CourseMembership cm = (CourseMembership) cmIterator.next();
          
          Id userId = cm.getUserId();
          String userIdString = userId.toExternalString();
          
          Id memberId = cm.getId();
          String memberIdString = memberId.toExternalString();
          
          User user = UserDbLoader.Default.getInstance().loadById(userId);
          
          output += "<student>";
          output += "<first_name>" + user.getGivenName() + "</first_name>";
          
          if (memberGrades.containsKey(memberIdString)) {
            output += "<grade>" + memberGrades.get(memberIdString) + "</grade>";
          }
          
          output += "<last_name>" + user.getFamilyName() + "</last_name>";
          output += "<student_id>" + user.getStudentId() + "</student_id>";
          output += "<username>" + user.getUserName() + "</username>";
          output += "</student>";
        }
        
        output += "</students>";
        output += "</grades>";
      } catch(Exception e) {
        ok = false;
        output = "<error>Course not found [" + e.getMessage() + "]</error>";
      }
      
    } else {
      ok = false;
      output = "<error>Invalid action</error>";
    }
  }
%>

<results><%= output %></results>