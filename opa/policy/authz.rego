package authz

import future.keywords.if
import data.lib.soap.lookup_user_from_soap

default allow = false

# Deny if the looked-up name is "alice" (case-insensitive), else allow.
allow if {
  input.user_id
  u := lookup_user_from_soap(input.user_id)
  lower(u.name) != "alice"
}