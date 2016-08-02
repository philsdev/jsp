<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <html>
      <head profile="http://www.w3.org/1999/xhtml/vocab">
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>UMOL API Results</title>
        <link type="text/css" rel="stylesheet" href="api.css" media="all" />
      </head>
      <body>
        <h1>UMassOnline API Results</h1>
        <xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="results/parameters">
    <h3>Parameters</h3>
	
    <table class="vert">
      <tr>
        <th>Action</th>
        <td><xsl:value-of select="action" /></td>
      </tr>
      <tr>
        <th>ID</th>
        <td><xsl:value-of select="id" /></td>
      </tr>
    </table>
  </xsl:template>
  
  <xsl:template match="results/error">
    <h3 class="error">ERROR: <xsl:value-of select="." /></h3>
  </xsl:template>
  
  <xsl:template match="results/user">
    <h3>User</h3>
    
    <table class="vert">
      <tr>
        <th>Username</th>
        <td><xsl:value-of select="username" /></td>
      </tr>
      <tr>
        <th>Batch ID</th>
        <td><xsl:value-of select="batch_id" /></td>
      </tr>
      <tr>
        <th>Student ID</th>
        <td><xsl:value-of select="student_id" /></td>
      </tr>
      <tr>
        <th>E-mail</th>
        <td><xsl:value-of select="email" /></td>
      </tr>
      <tr>
        <th>First Name</th>
        <td><xsl:value-of select="first_name" /></td>
      </tr>
      <tr>
        <th>Last Name</th>
        <td><xsl:value-of select="last_name" /></td>
      </tr>
      <tr>
        <th>Institution Role</th>
        <td><xsl:value-of select="institution_role" /></td>
      </tr>
      <tr>
        <th>System Role</th>
        <td><xsl:value-of select="system_role" /></td>
      </tr>
      <tr>
        <th>Is Available?</th>
        <td><xsl:value-of select="is_available" /></td>
      </tr>
      <tr>
        <th>Is Info Public?</th>
        <td><xsl:value-of select="is_info_public" /></td>
      </tr>
    </table>
    
    <xsl:for-each select="courses">
      <h3>Courses</h3>
    
      <table>
        <tr>
          <th>Course ID</th>
          <th>Title</th>
        </tr>
        <xsl:for-each select="course">
          <tr>
            <td><xsl:value-of select="course_id" /></td>
            <td><xsl:value-of select="title" /></td>
          </tr>
        </xsl:for-each>
      </table>   
    </xsl:for-each>
  </xsl:template>
   
  <xsl:template match="results/course">
    <h3>Course</h3>
	
    <table class="vert">
      <tr>
        <th>Batch ID</th>
        <td><xsl:value-of select="batch_id" /></td>
      </tr>
      <tr>
        <th>Course ID</th>
        <td><xsl:value-of select="course_id" /></td>
      </tr>
      <tr>
        <th>Description</th>
        <td><xsl:value-of select="description" /></td>
      </tr>
      <tr>
        <th>Is Available?</th>
        <td><xsl:value-of select="is_available" /></td>
      </tr>
      <tr>
        <th>Is Child?</th>
        <td><xsl:value-of select="is_child" /></td>
      </tr>
      <tr>
        <th>Is Parent?</th>
        <td><xsl:value-of select="is_parent" /></td>
      </tr>
      <tr>
        <th>Title</th>
        <td><xsl:value-of select="title" /></td>
      </tr>
    </table>
  </xsl:template>
  
  <xsl:template match="results/grades">
    <h3>Course</h3>
    
    <table class="vert">
      <tr>
        <th>Course ID</th>
        <td><xsl:value-of select="course_id" /></td>
      </tr>
      <tr>
        <th>Title</th>
        <td><xsl:value-of select="title" /></td>
      </tr>
    </table>
    
    <h3>Gradebook Column</h3>
    
    <table class="vert">
      <tr>
        <th>Column Name</th>
        <td><xsl:value-of select="gradebook/column/name" /></td>
      </tr>
      <tr>
        <th>Is External Grade?</th>
        <td><xsl:value-of select="gradebook/column/is_external_grade" /></td>
      </tr>
      <tr>
        <th>Is Visible?</th>
        <td><xsl:value-of select="gradebook/column/is_visible" /></td>
      </tr>
      <tr>
        <th>Is Scorable?</th>
        <td><xsl:value-of select="gradebook/column/is_scorable" /></td>
      </tr>
    </table>
    
    <h3>Grades</h3>
    
    <table>
      <tr>
        <th>First Name</th>
        <th>Last Name</th>
        <th>Student ID</th>
        <th>Username</th>
        <th>Grade</th>
      </tr>
      <xsl:for-each select="students/student">
        <tr>
          <td><xsl:value-of select="first_name" /></td>
          <td><xsl:value-of select="last_name" /></td>
          <td><xsl:value-of select="student_id" /></td>
          <td><xsl:value-of select="username" /></td>
          <td><xsl:value-of select="grade" /></td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>
  
</xsl:stylesheet>