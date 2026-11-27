#!/usr/bin/env bash
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Сценарий необходимо запускать от root."
  exit 1
fi

id user >/dev/null

install -d \
  -m 0700 \
  -o user \
  -g "$(id -gn user)" \
  /home/user/.ssh

install \
  -m 0600 \
  -o user \
  -g "$(id -gn user)" \
  /tmp/lab3-authorized-key.pub \
  /home/user/.ssh/authorized_keys

printf '%s\n' \
  'user ALL=(ALL:ALL) NOPASSWD: ALL' \
  > /etc/sudoers.d/90-lab3-user

chmod 0440 /etc/sudoers.d/90-lab3-user

visudo -cf /etc/sudoers.d/90-lab3-user

include_line='@include /etc/sudoers.d/90-lab3-user'
if [ "$(tail -n 1 /etc/sudoers)" != "$include_line" ]; then
  {
    cat /etc/sudoers
    printf '\n%s\n' "$include_line"
  } | visudo -cf /dev/stdin

  printf '\n%s\n' "$include_line" >> /etc/sudoers
fi

visudo -c

systemctl enable ssh
systemctl set-default multi-user.target

echo "SSH-ключ установлен."
echo "Правило sudo подключено после остальных правил и проверено."
