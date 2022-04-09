# GCE Backup Overview



## Configure GCE Backup

1. create the cloud source repository
```
gcloud source repos create gce-backup
```

2. configure credencial for the cloud source repository
```
touch ~/.gitcookies
chmod 0600 ~/.gitcookies
git config --global http.cookiefile ~/.gitcookies
echo "source.developers.google.com FALSE / TRUE 2147483647 o git-user=$(gcloud auth print-access-token)" > ~/.gitcookies
```

3. push the source code to the cloud source repository
```
git clone https://github.com/klin0024/gce-backup.git
cd gce-backup
git remote add google https://source.developers.google.com/p/gcp-expert-sandbox-allen/r/gce-backup
git push google
```

4. create the Cloud Pub/Sub topics 
```
gcloud pubsub topics create gce-backup --project=<YOUR-PROJECT-ID>
```

5. create the Cloud Build triggers
```
gcloud alpha builds triggers create pubsub --project=<YOUR-PROJECT-ID> \
--name=gce-backup \
--topic=projects/<YOUR-PROJECT-ID>/topics/gce-backup \
--substitutions=_INSTANCES='$(body.message.data.instances)',_RETAIN_DAYS='$(body.message.data.retainDays)' \
--repo=https://source.developers.google.com/p/<YOUR-PROJECT-ID>/r/gce-backup --branch=master --build-config=cloudbuild.yaml
```

7. create a Cloud Scheduler job 
```
gcloud scheduler jobs create pubsub gce-backup --project=<YOUR-PROJECT-ID> --location=<YOUR-LOCATION> \
--schedule "15 2 * * *" --time-zone='<YOUR-TIMEZONE>' \
--topic gce-backup \
--message-body '{"instances":"bastion-vm:us-central1-c docker:us-central1-a win2016:us-central1-a","retainDays":"7"}'
```