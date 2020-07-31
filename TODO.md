# TODO

* add naive handling of follow request inside `volatile_social_network`
* add naive handling of user wall request inside `volatile_social_network`
* refactor parsing mechanism of cli.ex in order to remove cond complexity
* remove duplication inside `volatile_social_network` about checking if the needed process already exists
* change logic in order to not pull messages and users info from repository every time (wall and timeline gen_server(s) ?)
* address strange random compilation errors on tets run
* add code docs and evaluate [Doctor](https://github.com/akoutmos/doctor) library