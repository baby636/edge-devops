Get All Settings (Integration, Component, dummy, QA, etc)!

// Build Image with all test settings
docker build -t ${imageName} .

// Run Unit Tests
docker run -v $(pwd)/coverage:/usr/app/coverage --network=host --name ${service}unit-test ${imageName} unit-test

// Setup mockups for component-tests
docker-compose up -d
// Run Component Tests
docker run -v $(pwd)/coverage:/usr/app/coverage --network=host --name ${service}component-test ${imageName} component-test
docker-compose down

// Run Integration Tests
docker run -v $(pwd)/coverage:/usr/app/coverage --network=host --name ${service}integration-test ${imageName} integration-test

// Deploy to QA
deploy to QA-ENV

// Run End To End Tests
build 'End-To-End'
docker run -v $(pwd)/coverage:/usr/app/coverage --network=host --name ${service}end_to_end end_to_end

// Deploy to Production
deploy to QA-ENV


unit-test

//merge this two
component-test
integration-test

docker-compose

/usr/app/coverage


pass in config location as ENV of defualt to local file