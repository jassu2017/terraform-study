locals {
  iml_data         = file("./users.yml")
  iml_data_decoded = yamldecode(local.iml_data)


  //get all users name accross diff teams

  all_users_name = toset(concat(
    local.iml_data_decoded.developers[*].username,
    local.iml_data_decoded.operations[*].username,
    local.iml_data_decoded.db_admins[*].username,
    local.iml_data_decoded.security[*].username


  ))

  // to get all the group names

  all_group_names = toset(flatten([
    yamldecode(local.iml_data).developers[*].groups,
    yamldecode(local.iml_data).operations[*].groups,
    yamldecode(local.iml_data).db_admins[*].groups,
    yamldecode(local.iml_data).security[*].groups

    ])
  )

  //list of all teams from yaml

  teams = [
    local.iml_data_decoded.developers,
    local.iml_data_decoded.operations,
    local.iml_data_decoded.db_admins,
    local.iml_data_decoded.security

  ]

  //extract users and their groups as pair

  pair_users_group = {
    for pair in flatten(
      [
        for team in local.teams : [
          for user in team : [
            for group in user.groups : {
              username = user.username,
              group    = group
            }
          ]
        ]
      ]
    ) : "${pair.username}-${pair.group}" => pair
  }



  //craete pair of users and  their directly  assigned persmissions

  pair_user_permission = {
    for pair in flatten(
      [
        for team in local.teams : [
          for user in team : [
            for permission in user.permissions : {
              username   = user.username,
              permission = permission
            }
          ]
        ]
      ]
    ) : "${pair.username}-${pair.permission}" => pair
  }


  // get group and their policies from the yaml

  groups_policies = local.iml_data_decoded.groups

  //create a pair of groups and their assigned policies

  pair_group_policy = {
    for pair in flatten([
      for group_name, group_obj in local.groups_policies : [
        for policy in lookup(group_obj, "policies", []) : {
          group_name = group_name
          group_obj = policy

        }
      ]
    ]) : "${pair.group_name}-${pair.group_obj}" => pair
  }

  password_policy = local.iml_data_decoded.password_policy
}

// create iam user of all team members

resource "aws_iam_user" "users" {

  for_each = local.all_users_name
  name     = each.value
}

//generate access key for users

resource "aws_iam_access_key" "user_key" {
  for_each = local.all_users_name
  user     = each.key

}

//setup console access ofr users with initial pwd  req

resource "aws_iam_user_login_profile" "user_login_profile" {
  for_each                = local.all_users_name
  user                    = each.key
  password_length         = 20
  password_reset_required = true

}

//configure org wise password policy settings

resource "aws_iam_account_password_policy" "password_policies" {

  minimum_password_length      = local.password_policy.minimum_length
  require_uppercase_characters = local.password_policy.require_uppercase
  require_lowercase_characters = local.password_policy.require_lowercase
  require_numbers              = local.password_policy.require_numbers
  require_symbols              = local.password_policy.require_symbols
  max_password_age             = local.password_policy.max_age_days
  password_reuse_prevention    = local.password_policy.prevent_reuse

  allow_users_to_change_password = true

}

// create iam groups of diff team roles

resource "aws_iam_group" "groups" {
  for_each = local.all_group_names
  name     = each.value

}

//assign users to their respective iam groups

resource "aws_iam_user_group_membership" "pairing_user_groups" {
  for_each = local.pair_users_group
  user     = each.value.username
  groups   = [each.value.group]

}

//attach aws_iam managed policies to aws group

resource "aws_iam_group_policy_attachment" "group_policy_attachment" {
  for_each   = local.pair_group_policy
  group      = each.value.group_name
  policy_arn = "arn:aws:iam::aws:policy/${each.value.group_obj}"

}

// attache aws managed policy directly to user

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {

  for_each = local.pair_user_permission

  user       = each.value.username
  policy_arn = "arn:aws:iam::aws:policy/${each.value.permission}"

}





