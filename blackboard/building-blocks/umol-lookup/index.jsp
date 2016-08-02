<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<%@ page import="blackboard.platform.plugin.*"%>
<%@ page import="blackboard.platform.db.*"%>
<%@ page import="blackboard.db.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ taglib uri="/bbNG" prefix="bbNG"%>

<%
  BbDatabase db = null;
  ConnectionManager cm = null;
  Connection c = null;
  Statement st = null;
  ResultSet rs = null;
  ResultSetMetaData rsmd = null;
  
  int rowCount = 100;
  
  String output = "";
  String sql = "";
  String item = "";
  String itemOptions = "";
  String column = "";
  String jsColumnOptions = "";
  String value = "";
  String colValue = "";
  String colType = "";
  String operator = "";
  String operatorOptions = "";
  String operatorArray[] = {"equals", "contains", "starts with", "ends with"};
  
  Map<String, String> items = new HashMap<String, String>();
  Map<String, String> courseColumns = new HashMap<String, String>();
  Map<String, String> userColumns = new HashMap<String, String>();
    
  if (request.getParameter("item") != null) {
    item = request.getParameter("item");
  }
  
  if (request.getParameter("column") != null) {
    column = request.getParameter("column");
  }
  
  if (request.getParameter("operator") != null) {
    operator = request.getParameter("operator");
  }
  
  if (request.getParameter("value") != null) {
    value = request.getParameter("value").toLowerCase();
  }
  
  for (int operatorIndex=0; operatorIndex < operatorArray.length; operatorIndex++) {
    operatorOptions += "<option value='" + operatorArray[operatorIndex] + "'";
    
    if (operator.equals(operatorArray[operatorIndex])) {
      operatorOptions += " selected='selected'";
    }
    
    operatorOptions += ">" + operatorArray[operatorIndex] + "</option>";
  }
    
  // add items
  items.put("courses", "course_main");
  items.put("users", "users");
  
  Set itemsSet = items.entrySet();
  Iterator itemIterator = itemsSet.iterator();
  
  while(itemIterator.hasNext()) {
    Map.Entry itemMapEntry = (Map.Entry)itemIterator.next();
    String itemKey = (String)itemMapEntry.getKey();
    
    itemOptions += "<option value='" + itemKey + "'";
    
    if (item.equals(itemKey)) {
      itemOptions += " selected='selected'";
    }
    
    itemOptions += ">" + itemKey + "</option>";
  }
  
  // add course columns
  courseColumns.put("CourseID", "course_id");
  courseColumns.put("BatchUID", "batch_uid");
  courseColumns.put("CourseName", "course_name");
  
  jsColumnOptions += " columnOptions['courses'] = [];";
  
  Set courseColumnsSet = courseColumns.entrySet();
  Iterator courseColumnsIterator = courseColumnsSet.iterator();
  
  while(courseColumnsIterator.hasNext()) {
    Map.Entry courseColumnMapEntry = (Map.Entry)courseColumnsIterator.next();
    String courseColumnKey = (String)courseColumnMapEntry.getKey();
    
    jsColumnOptions += " columnOptions['courses'].push('" + courseColumnKey + "');";
  }
  
  // add user columns
  userColumns.put("UserID", "user_id");
  userColumns.put("BatchUID", "batch_uid");
  userColumns.put("FirstName", "firstname");
  userColumns.put("LastName", "lastname");
  userColumns.put("Email", "email");
  
  jsColumnOptions += " columnOptions['users'] = [];";
  
  Set userColumnsSet = userColumns.entrySet();
  Iterator userColumnsIterator = userColumnsSet.iterator();
  
  while(userColumnsIterator.hasNext()) {
    Map.Entry userColumnMapEntry = (Map.Entry)userColumnsIterator.next();
    String userColumnKey = (String)userColumnMapEntry.getKey();
    
    jsColumnOptions += " columnOptions['users'].push('" + userColumnKey + "');";
  }
  
  int itemLength = 0;
  int colCount = 0;  
  int rowIndex = 0;
  
  if (item.length() > 0 && column.length() > 0 && operator.length() > 0) {
  
    //output += "<!-- <p>" + item + "|" + column + "|" + operator + "</p> -->";
    
    if (items.containsKey(item)) {
      String tableName = (String)items.get(item);
      String columnName = "";
      
      if (item.equals("courses")) {
        columnName = (String)courseColumns.get(column);
      } else {
        columnName = (String)userColumns.get(column);
      }
      
      sql = "SELECT *";
      sql += " FROM " + tableName;
      sql += " WHERE LOWER(" + columnName + ")";
      
      if (operator.equals("contains")) {
        sql += " LIKE '%" + value + "%'";
      } else if (operator.equals("starts with")) {
        sql += " LIKE '" + value + "%'";
      } else if (operator.equals("ends with")) {
        sql += " LIKE '%" + value + "'";
      } else {
        sql += " = '" + value + "'";
      }
      
      //output += "<!-- <p>" + sql + "</p> -->";
      
      try {
        db = JdbcServiceFactory.getInstance().getDefaultDatabase();
        cm = db.getConnectionManager();
        c = cm.getDefaultConnection();
        
        st = c.createStatement();
        rs = st.executeQuery("SELECT * FROM (" + sql + ") WHERE rownum <= " + rowCount);
        rsmd = rs.getMetaData();
        colCount = rsmd.getColumnCount();
        
        output += "<table class='results'>";
        
        // column names
        output += "<tr>";
        output += "<th></th>";
        for (int idx=1; idx <= colCount; idx++) {
          output += "<th>" + rsmd.getColumnName(idx) + "</th>";
        }
        output += "</tr>";     
        
        while (rs.next()) {
          rowIndex++;
          
          output += "<tr>";
          output += "<td>" + rowIndex + "</td>";
          
          for (int ci=1; ci <= colCount; ci++) {
            colType = rsmd.getColumnTypeName(ci).toUpperCase();
            output += "<td>";
            if (colType.equals("BLOB") || colType.equals("BFILE")) {
              output += "[ " + colType + " ]"; 
            } else {
              output += rs.getString(ci);
            }
            output += "</td>";
          }
          output += "</tr>";
        }
        
        output += "</table>";
        
        rs.close();
        st.close();
      } catch(SQLException ex) {
        output = "<h3>Db ERROR!</h3>";
        output += "<p>" + ex.getMessage() + "</p>";
      } catch(Exception e) {
        output = "<h3>ERROR!</h3>";
        output += "<div>" + e + "</div>";
      } finally {
        cm.releaseDefaultConnection(c);   
      }
    }
  }
  
  
%>

<bbNG:genericPage bodyClass="popup">  
  <bbNG:cssBlock>
    <style type="text/css">
      textarea { border: 1px solid #999999; width: 800px; height: 200px; overflow: auto; padding: 2px; }
      input[type=password] { border: 1px solid #999999; width: 200px; padding: 2px; }
      table.results { border: 1px solid #000000; margin-top: 10px; }
      table.results tr th { background-color: #999999; text-align: center; font-weight: bold; padding: 5px; }
      table.results tr td { text-align: left; padding: 5px; }
      table.results tr:nth-child(even) td { background-color: #FFFFFF; }
      table.results tr:nth-child(odd) td { background-color: #EEEEEE; }
    </style>
  </bbNG:cssBlock>
  <bbNG:jsBlock>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <script type="text/javascript">
      var columnOptions = {}; <%= jsColumnOptions %>
      var currentColumn = '<%= column %>';
      
      jQuery.noConflict();
      
      jQuery().ready( function() {    
        setColumnOptions(true);
        
        jQuery('#item-option').change(function() {
          setColumnOptions(false);
          jQuery('#value').val('');
        });
      });
      
      function setColumnOptions(setColumnName=false) {        
        var currentItem = jQuery('#item-option').val();
        
        jQuery.each(columnOptions, function(item_index, item_value_array) {
          if (item_index == currentItem) {
            var currentItemOptions = '';
            
            jQuery.each(item_value_array, function(column_index, column_value) {
              currentItemOptions += '<option value="' + column_value + '">' + column_value + '</option>';
            });
            
            jQuery('#column-options').html(currentItemOptions);
          }
        });
        
        if (setColumnName) {
          jQuery('#column-options').val(currentColumn);
        }
      }
    </script>    
  </bbNG:jsBlock>
  <bbNG:pageHeader instructions="This is the read-only item lookup">
    <bbNG:pageTitleBar title="UMassOnline Admin Item Lookup" />
  </bbNG:pageHeader>
  
  <form method="post">
    <p>
      <span>I'm looking for</span>
      <span><select name="item" id="item-option"><%= itemOptions %></select></span>
      <span>where</span>
      <span><select name="column" id="column-options"></select></span>
      <span><select name="operator"><%= operatorOptions %></select></span>
      <span><input type="text" name="value" value="<%= value %>" id="value" /></span>
      <span><button type="submit">GO</button></span>
    </p>
  </form>
  
  <%= output %>
  
</bbNG:genericPage>