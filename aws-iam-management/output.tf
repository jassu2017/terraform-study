output "iml_data_without_decoding" {
  value = local.iml_data
}

output "iml_data_with_decoding" {
  value = local.iml_data_decoded
}

output "users_name" {
  value = local.all_users_name
}

output "group_names" {
  value = local.all_group_names
}

output "teams_names" {
  value = local.teams
}

output "policy_names" {
  value = toset(flatten([
    yamldecode(local.iml_data).developers[*].permissions,
    yamldecode(local.iml_data).operations[*].permissions,
    yamldecode(local.iml_data).db_admins[*].permissions,
    yamldecode(local.iml_data).security[*].permissions

  ]))
}

output "pairing_users_with_groups" {
  value = local.pair_users_group
}

output "giving_permissions_to_users" {
  value = local.pair_user_permission
}

output "group-group_policy" {
  value = local.groups_policies
}

output "pairing_policies_with_group" {
  value = local.pair_group_policy
}

output "password_policies" {
  value = local.password_policy
}

