resource "aws_autoscaling_policy" "test-asg-scale-up" {
    name = "test-asg-scale-up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.test-asg-01.name}"
}

resource "aws_autoscaling_policy" "test-asg-scale-down" {
    name = "test-asg-scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = "${aws_autoscaling_group.test-asg-01.name}"
}