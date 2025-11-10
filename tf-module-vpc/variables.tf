# variable "sample_default_security_group_ingress" {
#     type = list(map(string))

#     description = "List of maps of ingress rules to set on the default security group"

#     default = [
#         {
#         description      = "SSH"
#         from_port        = 22
#         to_port          = 22
#         protocol         = "tcp"
#         cidr_blocks      = ["0.0.0.0/0"]  
#         ipv6_cidr_blocks = []
#         prefix_list_ids = []
#         security_groups = []
#         self = false
#         }
#     ]
        
        
    
    
# }

# variable "sample_default_security_group_egress" {

#      type = list(map(string))

#     description = "List of maps of egress rules to set on the default security group"

#     default = [
#         {
#       description      = "for all outgoing traffics"
#       from_port        = 0
#       to_port          = 0
#       protocol         = "-1"
#       cidr_blocks      = ["0.0.0.0/0"]
#       ipv6_cidr_blocks = []
#       prefix_list_ids = []
#       security_groups = []
#       self = false
#     }
#     ]
        
        
    
    
# }



