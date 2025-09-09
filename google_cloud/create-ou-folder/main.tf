# main.tf

# Only create folders if customer_folder_names is not empty AND we have a parent_folder
module "folders" {
  source  = "terraform-google-modules/folders/google"
  version = "~> 4.0"
  count   = length(var.customer_folder_names) > 0 && var.parent_folder != "" ? 1 : 0

  parent = "folders/${var.parent_folder}"

  names = var.customer_folder_names

  set_roles = true

  all_folder_admins = var.all_folder_admins
}

# Only create IAM binding if folders are created
resource "google_folder_iam_binding" "owners" {
  count  = length(var.customer_folder_names) > 0 && var.parent_folder != "" ? 1 : 0

  folder = module.folders[0].id
  role   = "roles/resourcemanager.projectCreator"

  members    = var.deployer_member
  depends_on = [module.folders]
}