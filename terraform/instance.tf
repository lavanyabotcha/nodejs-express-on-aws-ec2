resource "aws_instance" "main" {
  ami                  = "${data.aws_ami.amazon-2.id}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.main.name}"
  user_data = "${data.template_file.user_data.rendered}"

  vpc_security_group_ids = [
    "${aws_security_group.http.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.custom-tcp.id}",
    "${aws_security_group.allow_all_outbound.id}",
  ]

  tags = {
    Name = "Sample-App"
  }

} 