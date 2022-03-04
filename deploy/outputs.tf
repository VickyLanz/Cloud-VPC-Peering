 output "vm-1" {
   value = module.vm.instance
   sensitive = true
 }
 output "vm-2" {
   value = module.vm-2.instance
   sensitive = true
 }