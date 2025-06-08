variable "name" {
   description = "This is the name of our company" 
   type = string
   default = "Corp"

}



variable "pub-key" {
   description = "This is my public ssh key"
   type = string
   default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeUa5PV8ZtnpxxWqs6G3fYT3zEAs6QTaLGgRSCTDR++ dmrxt@lilglocc"
   sensitive = true

}

variable "port-numbers" {
   description = "These are my port numbers"
   type = map(number)
   default = {
     "http" = 80
     "ssh" = 22
   }

}

variable "image" {
   description = "The machine image to be used"
   type = string
   default = "ami-084568db4383264d4"
}

variable "instance-type" {
    description = "The size of the vm"
    type = string
    default = "t2.micro"
}