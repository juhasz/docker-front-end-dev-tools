Docker image for Grunt-Bower-Compass builds
-------------------------------------------

Usage:
Mount your application to `/app` as a volume, than run the desired command. Like this:

    docker run -v "$PWD":/app --rm juhasz/gbc grunt
