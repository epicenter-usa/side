# General Notes

#### Tidycensus R Package
https://cran.r-project.org/web/packages/tidycensus/tidycensus.pdf

https://walker-data.com/tidycensus/articles/basic-usage.html


#### Decennial data API reference: variables
https://api.census.gov/data/2010/dec/sf1/variables.html

#### American Community Survey data API reference: variables
https://api.census.gov/data/2018/acs/acs5/variables.html

#### Acesso direto aos shapes

No nível de Block Group, por estado
https://www2.census.gov/geo/tiger/TIGER2019/BG/

Estados Unidos todo
https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html

#### Dados de população das ilhas
https://www.census.gov/data/tables/time-series/dec/cph-series/cph-t/cph-t-8.html


#### Gerando a máscara dos EUA

https://www.keene.edu/campus/maps/tool/

#### Utils

http://bboxfinder.com/

#### Mapbox

To use setFeatureState, features must have an id.

https://docs.mapbox.com/mapbox-gl-js/api/map/#map#setfeaturestate

This method can only be used with sources that have a feature.id attribute. The feature.id attribute can be defined in three ways:

For vector or GeoJSON sources, including an id attribute in the original data file.
For vector or GeoJSON sources, using the promoteId option at the time the source is defined.
For GeoJSON sources, using the generateId option to auto-assign an id based on the feature's index in the source data. If you change feature data using map.getSource('some id').setData(..), you may need to re-apply state taking into account updated id values.


Options:

https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/#vector-promoteId

#### SO

##### Combining sf objects (spoiler: do.call(rbind, list_of_objs))

https://gis.stackexchange.com/questions/251641/how-to-combine-sfc-objects-from-r-package-sf

#### Useful references, maybe?

##### Segregation Map Washington Post
https://www.washingtonpost.com/graphics/2018/national/segregation-us-cities/

##### Immigrant dot map using tidycensus and mapbox

https://walker-data.com/mapboxapi/articles/mapping.html
https://github.com/walkerke/mb-immigrants
https://github.com/walkerke/mb-immigrants/blob/master/R/process_tracts.R
https://github.com/walkerke/mb-immigrants/blob/master/R/get_immigrant_data.R

##### ChoroplethR package
https://cran.r-project.org/web/packages/choroplethr/index.html

https://www.census.gov/data/academy/courses/choroplethr.html



### Processamento dos Counties

AK, County 270


#### Tilesets

World mask
tiagombp.cotke4p0
usa_mask-3mkk8m


|            | Municipalities     | Counties          |
|------------|----------------------------------------|
| Tileset ID | tiagombp.95ss0c3b  | tiagombp.cotke4p0 |
| Layer Name | municipalities     | counties-dl6qdm   |



### WaPo's Repo

Basic:

1. Clone Repo
2 and 3:
```
npm i
npm start
```

### SSH / Git / Cloning Linux

Connecting to GitHub with SSH
https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh

Generating a new SSH key (https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
Checking for existing SSH keys (https://docs.github.com/en/github/authenticating-to-github/checking-for-existing-ssh-keys)
Adding your SSH key to the ssh-agent
Adding a new SSH key to your GitHub account (https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account)
* Installing xclip
* Copying the SSH key to the clipboard
Testing your SSH connection (https://docs.github.com/en/github/authenticating-to-github/testing-your-ssh-connection)

```bash
ssh-keygen -t rsa -b 4096 -C "tiagombp@gmail.com"`

ls -al ~/.ssh

eval "$(ssh-agent -s)"

ssh-add /home/tiago/.ssh/id_rsa

sudo apt-get install xclip

xclip -sel clip < /home/tiago/.ssh/id_rsa.pub

ssh -T git@github.com
```

#### Google Cloud

34.123.140.243

sudo apt-get update

curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh --output miniconda.sh

bash miniconda.sh

export PATH="$HOME/miniconda3/bin:$PATH"

# test
conda create --name app
# environment location: /home/tiagombp/miniconda3/envs/app

conda init
sudo reboot

# em algum diretorio
conda activate app

vi app.py

```python
import flask, json
from flask import request, jsonify, after_this_request
app = flask.Flask(__name__)
@app.route("/", methods=['GET'])
def answer_basic():
    return jsonify("hi! Up and running")
@app.route("/coords", methods=['GET'])
def answer_coords():
    @after_this_request
    def add_header(response):
        response.headers['Access-Control-Allow-Origin'] = '*'
        return response
    out = "{'nearest_landmark': {'bbox': [[-74.25909, 40.477399], [-73.700009, 40.917577]], 'display_text': {'compl
ement': 'a place with really '  'bright lights',  'landmark': 'Times Square'}, 'input_point': ['40.757952', '-73.98
558100000001'], 'place_id': '3651000', 'place_name': 'New York City', 'radius': {'first_stop': {'inner_point': [-73
.98558100000001, 40.757952], 'outer_point': [-73.98483349023438, 40.757952]},  'second_stop': {'inner_point': [-73.
98558100000001,  40.757952],  'outer_point': [-73.98125612207032,  40.757952]},  'today': {'inner_point': [-73.9855
8100000001,  40.757952],  'outer_point': [-73.96870600000001,  40.757952]}}, 'state_abbr': 'NY'},  'radius': {'firs
t_stop': {'inner_point': (-66.620918, 18.0102),  'outer_point': (-66.62017049023437, 18.0102)}, 'second_stop': {'in
ner_point': (-66.620918, 18.0102), 'outer_point': (-66.61226824414062, 18.0102)}, 'today': {'inner_point': (-66.620
918, 18.0102), 'outer_point': (-66.53548831250001, 18.0102)}},  'vanishing_place': {'bbox': [(-66.715244, 17.831509
), (-66.499601, 18.172479)],  'centroid': (-66.60725882398899, 18.002726643701546),  'id': '72113',  'pop_2019': 14
8863.0}}"
    return jsonify(out)
if __name__ == "__main__":
    app.run()
```

gunicorn -b :5000 --access-logfile - --error-logfile - app:app

# wsgi entry point

vi wsgi.py

```python
from app import app

if __name__ == "__main__":
    app.run()
```

# systemd service

sudo nano /etc/systemd/system/app.service

```
[Unit]
#  specifies metadata and dependencies
Description=Gunicorn instance to serve myproject
After=network.target
# tells the init system to only start this after the networking target has been reached
# We will give our regular user account ownership of the process since it owns all of the relevant files
[Service]
# Service specify the user and group under which our process will run.
User=tiagombp
# give group ownership to the www-data group so that Nginx can communicate easily with the Gunicorn processes.
Group=www-data
# We'll then map out the working directory and set the PATH environmental variable so that the init system knows w>
WorkingDirectory=/home/tiagombp/backend-epicenter
Environment="PATH=/home/tiagombp/miniconda3/envs/epicentro-usa"
# We'll then specify the commanded to start the service
ExecStart=/home/tiagombp/miniconda3/envs/epicentro-usa/bin/gunicorn -b unix:app.sock --workers=5 -m 007 --access-logfile - --error-logfile error.log --chdir code wsgi:app
# This will tell systemd what to link this service to if we enable it to start at boot. We want this service to st>
[Install]
WantedBy=multi-user.target
```

# starting and enabling gunicorn service

sudo systemctl start app
sudo systemctl enable app

A new file app.sock will be created in the project directory automatically.

# nginx

sudo apt-get install nginx

cd into /etc/nginx/

sudo nano /etc/nginx/sites-available/app

```
server {
    listen 443;
    server_name tiago.live;
    location / {
        include proxy_params;
        proxy_pass http://unix:/home/tiagombp/app/app.sock;
    }
}
```

sudo ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled

# test configuration file
sudo nginx -t

sudo systemctl restart nginx

# firewall
sudo ufw allow 'Nginx Full'

# certificate

https://certbot.eff.org/lets-encrypt/ubuntufocal-nginx

sudo snap install --classic certbot

sudo certboot --nginx

```
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/tiago.live/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/tiago.live/privkey.pem
   Your cert will expire on 2020-12-13. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot again
   with the "certonly" option. To non-interactively renew *all* of
   your certificates, run "certbot renew"
```

### MBTiles / The dots layer

Uploading a 2.4gb MBtiles file to Mapbox.

https://docs.mapbox.com/api/maps/#uploads

#### Get credentials

```
curl -X POST "https://api.mapbox.com/uploads/v1/tiagombp/credentials?access_token=YOUR MAPBOX ACCESS TOKEN
```

This endpoint requires a token with uploads:write scope.

accessKeyId	AWS Access Key ID
bucket	S3 bucket name
key	The unique key for data to be staged
secretAccessKey	AWS Secret Access Key
sessionToken	A temporary security token
url	The destination URL of the file

#### Install AWS CLI
https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html

#### Send mbtiles file to S3 bucket

```
$ export AWS_ACCESS_KEY_ID={accessKeyId}
$ export AWS_SECRET_ACCESS_KEY={secretAccessKey}
$ export AWS_SESSION_TOKEN={sessionToken}
$ aws s3 cp /path/to/file s3://{bucket}/{key} --region us-east-1
```

#### Create the upload

```bash
curl -X POST -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
  "url": "http://{bucket}.s3.amazonaws.com/{key}",
  "tileset": "{username}.{tileset-name}"
}' 'https://api.mapbox.com/uploads/v1/tiagombp?access_token=YOUR MAPBOX ACCESS TOKEN
This endpoint requires a token with uploads:write scope.
'
```

Response:

```json
{"id":"ckf8tv41o04pe29oinoazw0rp","name":null,"complete":false,"error":null,"created":"2020-09-18T22:41:46.886Z","modified":"2020-09-18T22:41:46.886Z","tileset":"tiagombp.people_usa","owner":"tiagombp","progress":0}%    
```


#### Checking the status

```
curl "https://api.mapbox.com/uploads/v1/tiagombp/{upload_id}?access_token=YOUR MAPBOX ACCESS TOKEN"
```

### shell scripts with parameters/arguments

```bash
vi teste.sh
```

```vi
#!/bin/bash
  
echo $1
ls $1.mbtiles -lt
```

```bash
tiagombp@instance-1:~/people-dots$ chmod +x teste.sh
tiagombp@instance-1:~/people-dots$ bash teste.sh people-usa
people-usa
-rw-r--r-- 1 tiagombp tiagombp 24576 Sep 22 17:13 people-usa.mbtiles
```

```vi
#!/bin/bash
echo "Processando State com FIPS $1"
echo jsons/$1*.json | xargs geojson-merge --stream > pop$1.json
tippecanoe -z14 -o pop$1.mbtiles -l people-usa --drop-densest-as-needed pop$1.json
```


