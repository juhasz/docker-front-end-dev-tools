Docker image for Front end development
--------------------------------------

Usage:
Mount your application to `/app` as a volume, than run the desired command. Like this:

    docker run -v "$PWD":/app --rm juhasz/fedt grunt
