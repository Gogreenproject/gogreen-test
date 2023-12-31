# Users
resource "aws_iam_user" "SysAdmin" {
  for_each = toset( ["sysadmin1", "sysadmin2"] )
  name     = each.key
}
resource "aws_iam_user" "DBAdmin" {
  for_each = toset( ["dbadmin1", "dbadmin2"] )
  name     = each.key
}
resource "aws_iam_user" "Monitoring" {
  for_each = toset( ["monitoruser1", "monitoruser2", "monitoruser3", "monitoruser4"] )
  name     = each.key
}

# Groups
resource "aws_iam_group" "sysadmin_group" {
  name     = "Sytem_Administrator_Group"
}
resource "aws_iam_group" "dbadmin_group" {
  name     = "Database_Administrator_Group"
}
resource "aws_iam_group" "Monitoring_Group" {
  name     = "Monitoring_Group"
}

# Membership
resource "aws_iam_group_membership" "team1" {
  name = "sysadmin_group-membership"
  for_each = toset( ["sysadmin1", "sysadmin2"] )
  users = [aws_iam_user.SysAdmin[each.key].name]
  group = aws_iam_group.sysadmin_group.name
 }
resource "aws_iam_group_membership" "team2" {
  name = "dbadmin_group-membership"
  for_each = toset( ["dbadmin1", "dbadmin2"] )
  users = [aws_iam_user.DBAdmin[each.key].name]
  group = aws_iam_group.dbadmin_group.name
 }
resource "aws_iam_group_membership" "team3" {
  name = "monitoring_group-membership"
  for_each = toset( ["monitoruser1", "monitoruser2", "monitoruser3", "monitoruser4"] )
  users = [aws_iam_user.Monitoring[each.key].name]
  group = aws_iam_group.Monitoring_Group.name
 }

# Group Policy
data "aws_iam_policy" "sysadmin" {
  arn = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
}

data "aws_iam_policy" "monitor" {
  arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

data "aws_iam_policy" "db_admin" {
  arn = "arn:aws:iam::aws:policy/job-function/DatabaseAdministrator"
}

# Group Policy attachment
resource "aws_iam_group_policy_attachment" "sysadmin" {
  policy_arn = data.aws_iam_policy.sysadmin.arn
  group = aws_iam_group.sysadmin_group.name
}

resource "aws_iam_group_policy_attachment" "monitor" {
  policy_arn = data.aws_iam_policy.monitor.arn
   group = aws_iam_group.Monitoring_Group.name
}

resource "aws_iam_group_policy_attachment" "db_admin" {
  policy_arn = data.aws_iam_policy.db_admin.arn
  group      = aws_iam_group.dbadmin_group.name
}