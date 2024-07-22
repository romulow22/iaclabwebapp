all:
  children:
    web:
      hosts:
%{ for ip in web_ips ~}
        ${ip}:
%{ endfor ~}
    db:
      hosts:
%{ for ip in db_ips ~}
        ${ip}:
%{ endfor ~}
  vars:
    ansible_user: ${vm_user}