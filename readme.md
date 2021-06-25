Credit:
https://gist.github.com/byk0t/a9644fd2360a9662702568459df289fc

How to use:
Create addons and config folders
Run sudo chmod -R 777 addons (We need it writable from inside the docker container, for example for an odoo_bin utility)
Run docker-compose up -d
Generate a module docker exec -d odoo-test_web_1 /usr/bin/odoo scaffold openacademy /mnt/extra-addons && sudo chown -R pavel:pavel addons/openacademy (pavel is a my user . If we don't change an owner we will not be able to edit a source code outside the container)

