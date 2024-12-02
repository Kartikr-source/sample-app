COMMIT_ID="$(git rev-parse --short=7 HEAD)"
gcloud builds submit --tag="${REGION}-docker.pkg.dev/${PROJECT_ID}/$REPO/hello-cloudbuild:${COMMIT_ID}" .

EXPORTED_IMAGE="$(gcloud builds submit --tag="${REGION}-docker.pkg.dev/${PROJECT_ID}/$REPO/hello-cloudbuild:${COMMIT_ID}" . | grep IMAGES | awk '{print $2}')"

echo "EXPORTED_IMAGE: ${EXPORTED_IMAGE}"

git checkout dev

sed -i "9c\    args: ['build', '-t', '$REGION-docker.pkg.dev/$PROJECT_ID/my-repository/hello-cloudbuild-dev:v1.0', '.']" cloudbuild-dev.yaml

sed -i "13c\    args: ['push', '$REGION-docker.pkg.dev/$PROJECT_ID/my-repository/hello-cloudbuild-dev:v1.0']" cloudbuild-dev.yaml

sed -i "17s|        image: <todo>|        image: $REGION-docker.pkg.dev/$PROJECT_ID/my-repository/hello-cloudbuild-dev:v1.0|" dev/deployment.yaml

git add .
git commit -m "Awesome Lab" 
git push -u origin dev

sleep 70

git checkout master

kubectl expose deployment development-deployment -n dev --name=dev-deployment-service --type=LoadBalancer --port 8080 --target-port 8080

sed -i "11c\    args: ['build', '-t', '$REGION-docker.pkg.dev/\$PROJECT_ID/my-repository/hello-cloudbuild:v1.0', '.']" cloudbuild.yaml

sed -i "16c\    args: ['push', '$REGION-docker.pkg.dev/\$PROJECT_ID/my-repository/hello-cloudbuild:v1.0']" cloudbuild.yaml

sed -i "17c\        image:  $REGION-docker.pkg.dev/$PROJECT_ID/my-repository/hello-cloudbuild:v1.0" prod/deployment.yaml

git add .
git commit -m "Awesome Lab" 
git push -u origin master

sleep 70

kubectl expose deployment production-deployment -n prod --name=prod-deployment-service --type=LoadBalancer --port 8080 --target-port 8080

git checkout dev

sed -i '28a\	http.HandleFunc("/red", redHandler)' main.go

sed -i '32a\
func redHandler(w http.ResponseWriter, r *http.Request) { \
	img := image.NewRGBA(image.Rect(0, 0, 100, 100)) \
	draw.Draw(img, img.Bounds(), &image.Uniform{color.RGBA{255, 0, 0, 255}}, image.ZP, draw.Src) \
	w.Header().Set("Content-Type", "image/png") \
	png.Encode(w, img) \
}' main.go

sed -i "9c\    args: ['build', '-t', '$REGION-docker.pkg.dev/\$PROJECT_ID/my-repository/hello-cloudbuild-dev:v2.0', '.']" cloudbuild-dev.yaml

sed -i "13c\    args: ['push', '$REGION-docker.pkg.dev/\$PROJECT_ID/my-repository/hello-cloudbuild-dev:v2.0']" cloudbuild-dev.yaml

sed -i "17c\        image: $REGION-docker.pkg.dev/$PROJECT_ID/my-repository/hello-cloudbuild:v2.0" dev/deployment.yaml

git add .
git commit -m "Awesome Lab" 
git push -u origin dev

sleep 10

git checkout master

sed -i '28a\	http.HandleFunc("/red", redHandler)' main.go

sed -i '32a\
func redHandler(w http.ResponseWriter, r *http.Request) { \
	img := image.NewRGBA(image.Rect(0, 0, 100, 100)) \
	draw.Draw(img, img.Bounds(), &image.Uniform{color.RGBA{255, 0, 0, 255}}, image.ZP, draw.Src) \
	w.Header().Set("Content-Type", "image/png") \
	png.Encode(w, img) \
}' main.go


sed -i "11c\    args: ['build', '-t', '$REGION-docker.pkg.dev/\$PROJECT_ID/my-repository/hello-cloudbuild:v2.0', '.']" cloudbuild.yaml

sed -i "16c\    args: ['push', '$REGION-docker.pkg.dev/\$PROJECT_ID/my-repository/hello-cloudbuild:v2.0']" cloudbuild.yaml

sed -i "17c\        image: $REGION-docker.pkg.dev/$PROJECT_ID/my-repository/hello-cloudbuild:v2.0" prod/deployment.yaml

git add .
git commit -m "Awesome Lab" 
git push -u origin master

sleep 70

kubectl -n prod rollout undo deployment/production-deployment

kubectl -n prod get pods -o jsonpath --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

