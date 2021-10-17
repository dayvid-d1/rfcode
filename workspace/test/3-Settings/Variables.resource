*** Variables ***
${BROWSER}     %{AUTO_BROWSER}

${URL}    https://slims01.tst-24.aws.agilent.net/slims/login
${USERNAME}    david01
${PASSWORD}    david01

#${URL}    http://ec2-3-120-150-30.eu-central-1.compute.amazonaws.com:8080/slims/login
#${USERNAME}    admin
#${PASSWORD}    admin


#SLIMS Main Page
${SLIMS_MAIN_MENU}  SlimsMainMenu
${SLIMS_MENU}  slimsIcon

${SLIMS_USER_INFO}  UserInfoMenuButton
${SLIMS_CANVAS}  SectionCanvas

#SLIMS Menu
${SLIMS_PANEL}  SlimsButtonTileGrid 
${SLIMS_SEARCH}  search