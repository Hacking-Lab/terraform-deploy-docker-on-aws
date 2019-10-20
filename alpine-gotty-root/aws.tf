provider "aws" {
  profile    = "default"
  region     = "us-west-1"
}

resource "aws_key_pair" "myssh" {
  key_name   = "ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMFfE1OCN6hgCt+2JZ/1GCDwZfnV4ROK7nlWc2ZDD8rtlw5tIax+EjBmezY9+KpCAabGdl9k0NqcNxlE5fjp4hoK+Q9KbhIqP6vt16YTcDqMQyoeoQSV56fGOXuTH26DKT1AHxoE6WEWPdwsmVYp6bzIqIe3UGVQPklOUJwRyI7KowmW8YQgzNBMPwG9U/aOR8Rm1p3BFr2VH7MVul0ARTTwFF8nTPQvAXKMZzNfOZUAtN+nb2KTu7SXLCUhTsrG7td4eUSTRMJbB8XPxU2mDYmKBZanxXCASvTtjAKzgIsUvPD+7dXu9c8cqiYeYXJ584A0YbCou8y1Ds1tq8zka5 ibuetler@Ivans-MacBook-Pro.local"
}


resource "aws_instance" "alpine-gotty-root" {
  ami           = "ami-0dd655843c87b6930"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.myssh.key_name}"

  connection {
    host = "${self.public_ip}"
    user = "ubuntu"
    type = "ssh"
    private_key = "${file("${aws_key_pair.myssh.key_name}")}"
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
	"sudo apt-get update -y",
	"sudo apt-get upgrade -y",
	"sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
	"curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
	"sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
	"sudo apt-get update -y",
	"sudo apt-get install -y docker-ce",
        "sudo yum install -y docker",
        "sudo service docker start",
        "sudo docker pull hackinglab/alpine-gotty-root",
        "sudo docker run -d -p 80:8080 hackinglab/alpine-gotty-root"
    ]
  }
}
