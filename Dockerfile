
# multistage docker file

# 1 >

FROM golang:alpine AS Builder
WORKDIR /helloworld
COPY helloworld.go .
RUN GOOS=linux go build -a -installsuffix cgo -o helloworld .
#ENTRYPOINT ["./helloworld"]

FROM alpine:latest
WORKDIR /root
COPY --from=Builder /helloworld/helloworld .
ENTRYPOINT ["./helloworld"]


#alpine is the smallest, stripped of all version for any image.
#alpine:latest, will not have any runtime , or libraries, it is simple bash shell.

#once executable is available from previous build, we did not need the code or runtime, so 
#it is ok to delete it, and we do this by adding another stage.

#COPY --from=Builder /helloworld/helloworld  : copying from builder stage, a helloworld build from /helloworld dir 
# to pwd.

#need only one entrypoint/cmd , to later stage.

#--------------------------------------------------------------------------------------------------------------

# 2 >

FROM maven AS Builder1
RUN mkdir /usr/src/mymaven
WORKDIR /usr/src/mymaven
COPY ./ ./
RUN mvn install -DskipTests

FROM tomcat:alpine
WORKDIR webapps
COPY --from=Builder1 /usr/src/mymaven/target/java-tomcat-maven-example.war .
RUN rm -rf ROOT && mv java-tomcat-maven-example.war ROOT.war
CMD ["java","-jar","/usr/src/mymaven/target/ROOT.war"]


#--------------------------------------------------------------------------------------------------------------

>1.containers are increasingly became popular, but it do present some security risk to the 
> application as well as data

>2.containerization is one of the core stages in devops process where security must be looked on a serious note.

>3.container image can have many bugs and security vulnerabilitiues, which gives a good opportunity for the
> hackers to bet access to the application and data present in the containers.

>4.hence it is crucial to scan and audit the images and containers regularly.

>5.DevSecOps plays an important role in adding security to the devops processes, including scanning images
> and containers for bugs and vulnerabilities.

>6.while building docker images , mainly we are concerned for two things_
  a)Size of the image
  b)security of the image 

>7.the container images are comprised of several layers. so scanning each and every layer is very crucial in 
   devsecops, the smaller the image is, lesser is the possibility of it to get exposed to potential vulnerabilities

>8.SMALLER DOCKER IMAGES_ 

  1) container images should be small and lightweight as much as possible   
  2) they should pack only the application code and its dependancies. rest everything to be scrapped off
     to bring down its size including the build dependancies.
  3) smaller the images lesser is the attack surface area to the container and morever are easy to 
     distribute and deploy   
  4) larger images can have more software vulnerabilities in the form of dependancies including 
     potential security holes
  5) better to use alpine images like, FROM golang:alpine or FROM node:alpine 
  6) Alpine images are small and light weighted as they have many  files and programms removed, leaving 
     only the dependancies just enough to run the application 


>9.WHY SMALLER DOCKER IMAGES_

    1)they pack very few system utilities
    2)smaller container can be moved much easier and faster
    3)it makes pull-push operation faster and improves performance
    4)samller images are efficient in utilizing disk space and memory due to less running processes.


>10.HOW TO BUILD SMALLER IMAGES_

    1)follow the dockerfile best practices , while building the images. the overhead of scanning the docker images 
      for detecting vulnerabilities, investigating the security issues,and reporting and fixing them after the 
      deployment, can prevented by folloing best practices to build docker images_ 

    2)Do not run the container as ROOT.
    3)avoid copying unnecessary file, use .dockerignore
    4)merge layers 
    5)use alpine or distroless images as base image
    6)use multistage build 
    7)perform health checks
    8)avoid exposing unnecessary ports
    9)hardcoding the credentials
   10)dockerhub host up to 7 miilion repositories, base base must be selected wisely, not all images are secure.
   11)use tool like ancore image scanner to scan the images for vulnereabilities.


>11.What if multistage images , do not reduces the size of image, then_

    1)remove unwanted binaries like apt, yum, npm, bash, sh leaving only required dependancies
    2)pack only bare minimum dependancies needed to run container.
    3)use alpine images as a base image becouse  it is much easier to use standard debugging tools
      ans install dependancies 
    4)use distroless images, is a project from google (java user can use jib)  

>12.Alpin Linux_
    Alpin Linux is a linux distribution build around musl libc and busybox. it is only 5MB in size.
    which makes great base image for utilities and even production applications.
    by using alpin linux as base image, and adding only required dependancies/artifacts on top of it, 
    result in smaller and cleaner docker images. 


>13.Distroless Images_ 
    Distroless containers images are language focussed docker images, sans the operating system distribution. 
    it contains only application and its runtime dependancies, not other usual os package managers, linux shells
    or any such programm which we usually expect in a standard linux distribution.

    this approch creates a smaller attack surface, reduces complience scop and result in a smaller , lean and
    clean image and thius increases security.

    it is pioneered by GOOGLE. google have published the set of distroless images for different languages.
    distroless images do not have shell for dubugging. 

  >there are also a bare minimum stripped "scratch" images. These are very small images. 
  (may not support all image build, google it and read)


>14.Merge Layers of Image_  
    Use --squash flag on build
    The squash flag is an experimental feature. It allows you to merge the new layers into one layer 
    during the build time. To use it just add the flag to the build command: 
    
    >docker build --squash -t <image>.

    You can use it by activating the experimental features in the Docker settings.
      

>15.Container Security Tools_
    
    1)these tools scans the containers for all the vulnerabilituies and monitor them regularly against any attack, 
      issue or new bugs.

    2)they mostaly work by scanning installed os packages and compairing versions to CVE 
      (comman vulnerabilities and exposures) database.

    3)some of the container scanners are _ ANCHORE ENGINE, CLAIR, TWISTLOCK, QUALYS, BLACKDUG, CILIUM,
      SYSDIG FALCO, AQUASECURITY/ TRIVY  etc....... 

>----------------------------------------------------------------------------------------------------------------

>16.USING Anchore image Analyzer CLI_

    1)adding container image to analyse_ 
        anchore-cli image add <image_name>

    2)waiting for image to complate the analysis_ (to check if analysis is complete or not)
        anchore-cli image wait <image>

    3)list images analysed by anchore_ 
        anchore-cli image list 

    4)veiw the scan result and list out all of the known vulnerabilities_
        anchore-cli image <image>  

    5)to run policy check 
        anchore-cli evaluate check <image> --detail


>-----------------------------------------------------------------------------------------------------------------

>17.Using Trivy Image Analyser CLI__

    1) trivy --help 

    2) scanning image to analyse_ 
       trivy image <image:tag> 

    3) setting image vulnerabilty severity as per users need_ 
       trivy image <image:tag> --severity=<LEVEL> -->CRITICAL/HIGH/MEDIUM/LOW

    4) to get format in json format/ other format also available
       trivy image <image:tag> --severity=<LEVEL> --format json




#------------------------------------------------------------------------------------------------------------------            

>every command in dockerfile, runs a root user/commands, it never requires a sudo permission.


>Best Practice for bilding images 

1.never use the latest image  and if possible pass the image version as argument 

ARG TAG=18.04
FROM ubuntu:$TAG 


2.while copying the files , use full paths, Regular expression and user 'Dockerignore' file to 
  avoid copying uncessary files.
  Also chnage the working directory before copying the files.

WORKDIR /appl 
COPY *.java . 


3.merge the multipleRUN commands in to single command, it will reduce the number of layers.

RUN apt get update && apt install curl -y  && curl -k http://ip 

or

RUN apt update -y && \
    apt install curl -y && \
    curl -k http://ip:port 



4.never pass the secrete data in environmental variable , pass it as environmental variable ,
while buiding image only.

ENV DATABASE postgres

>docker run --name dummydatabase -e PASSWORD=1234 test:1.0   --->passing env var using -e flag.


5.CMD AND ENTRYPOINT instruction , we need to use executable format. we can also remove sh/bash for security purpose
  before execution on CMD/ ENTRYPOINT , and we can call binary directaly.

  > suppose we are pinging some ip on image ixecution, then_

   RUN rm -rf /bin/bash   ---> this will remove only bash.
   CMD 8.8.8.8
   ENTRYPOINT ping
 
 in above case , overall command will be ping 8.8.8.8, however ping wont be starting process as both the 
 instructions are in shell format. so, it will be like, /bin/bash -c "ping 8.8.8.8".

 now, execute by calling the binary directaly_ 

  RUN rm -rf /bin/bash   ---> this will remove only bash.
  CMD ["8.8.8.8"]
  ENTRYPOINT ["/bin/ping"]

   so, it will be like, "/bin/ping", "8.8.8.8"



6.one of the best practice is use non root user for entrypoint and cmd instruction, this can be done by 
  switching to non root user using USER instruction.
  Now this will create a problem, while running a RUN instruction that needs a root permission. this can be
  metigated by running a all instructions as root user and switching to normal user , just before the 
  CMD/ ENTRYPOINT instruction. 

  ARG TAG=18.04
  FROM ubuntu:$TAG 
  USER root                   (not needed , by default runs as a root)
  RUN apt update -y && \
      apt install curl -y && \
      curl -k http://ip:port 
  RUN rm -rf /bin/bash    
  USER developer              (user can be created by using a RUN instruction with normal linux commands)
  CMD ["8.8.8.8"]
  ENTRYPOINT ["/bin/ping"]



7.using distroless images_
  these images do not any debugging utilities like sh, ping, ls, curl etc.
  however, google also provides distroless images with nonroot user, images with debugging utilities, 
  and debugging utilities with nonroot user. 

 >https://github.com/GoogleContainerTools/distroless


gcr.io/distroless/static-debian11:debug , will have all the debug utilities.
gcr.io/distroless/static-debian11:debug-nonroot , will have debug utilities for non root user.

FROM gcr.io/distroless/static-debian11:debug



8. one other best practice is to if possible ,not execute changing instruction at start of the docker file. 
   instruction like COPY, in which data keep on chnaging , it is advisable to use this at end , this is becouse
   docker build the images using cache of already build images and all the instruction after changed instruction
   will run again , increasing the execution time and engedging the storage. 
 
  ARG TAG=18.04
  FROM ubuntu:$TAG 
  USER root                   (not needed , by default runs as a root)
  RUN apt update -y && \
      apt install curl -y && \
      curl -k http://ip:port 
  RUN rm -rf /bin/bash 
  COPY *.go .   
  USER developer              (user can be created by using a RUN instruction with normal linux commands)
  CMD ["8.8.8.8"]
  ENTRYPOINT ["/bin/ping"]



9.while building images, remove unnecessary dependancies also after building remove package manager cache.

  ARG TAG=18.04
  FROM ubuntu:$TAG 
  RUN apt-get update -y && \
      apt-get install --no-install-recommends \
      openjdk-8-jdk && \
      rm -rf /var/lib/apt/lists/*       (--->remove the cache) 
  COPY target/app.jar  /app
  CMD ["java","jar","/app/app.jar"]    



>----------------------------------------------------------------------------------------------------------------
*****************************************************************************************************************


>DOCKER SECURITY.






 
  
