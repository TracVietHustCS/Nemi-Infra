output "config" {
  value = {
    user     = aws_db_instance.database.username
    password = aws_db_instance.database.password
    hostname = aws_db_instance.database.address
    port     = aws_db_instance.database.port
  }
}