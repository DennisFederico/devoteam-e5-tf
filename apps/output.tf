output "result" {
    value = <<-EOT
USER -> ${module.application["second_app"].application_user}
KEY  -> ${module.application["second_app"].api_key}
PORPS-> 
${module.application["second_app"].app_properties}
EOT
    sensitive = false
}

output "all_result" {
    value = module.application
    sensitive = false
}