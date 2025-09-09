resource "googleworkspace_user" "user" {
  primary_email = var.primary_email
  password      = var.password
  hash_function = "MD5"

  name {
    family_name = var.family_name
    given_name  = var.given_name
  }

  organizations {
    department = var.department
    location   = var.location
    name       = var.org_name
    primary    = true
    symbol     = "DUMI"
    title      = "member"
    type       = "work"
  }
}

data "googleworkspace_user" "user_id" {
  id = googleworkspace_user.user.id
}

data "googleworkspace_user" "user_email" {
  primary_email = googleworkspace_user.user.primary_email
}

resource "local_file" "user" {
  content = jsonencode({
    id    = base64encode(data.googleworkspace_user.user_id.id)
    email = base64encode(data.googleworkspace_user.user_email.primary_email)
  })
  filename = "../../../../customer_user.json"
}