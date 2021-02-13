resource "aws_vpc_peering_connection" "peer" { # VPC 1
  vpc_id        = var.vpc_id
  peer_vpc_id   = var.peer_vpc_id
#   peer_owner_id = data.aws_caller_identity.peer.account_id
  auto_accept   = false

  tags = {
    Side = "Requester"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" { # VPC 2
#   provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

