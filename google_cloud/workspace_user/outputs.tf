output "user_id" {
  value = data.googleworkspace_user.user_id.id
}

output "user_email" {
  value = data.googleworkspace_user.user_email.primary_email
}