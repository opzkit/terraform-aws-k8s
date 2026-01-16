# Changelog

## [0.25.1](https://github.com/opzkit/terraform-aws-k8s/compare/v0.25.0...v0.25.1) (2026-01-16)


### Bug Fixes

* **vars:** make taints and labels optional in vars.tf ([#243](https://github.com/opzkit/terraform-aws-k8s/issues/243)) ([878a2f4](https://github.com/opzkit/terraform-aws-k8s/commit/878a2f447d302b4fd45b87c7fb54bcc249834447))


### Miscellaneous Chores

* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.24.0 ([#242](https://github.com/opzkit/terraform-aws-k8s/issues/242)) ([f8757dd](https://github.com/opzkit/terraform-aws-k8s/commit/f8757dd116f629fc4b41b78955f01c54ab587446))
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.104.1 ([#237](https://github.com/opzkit/terraform-aws-k8s/issues/237)) ([cbdeecb](https://github.com/opzkit/terraform-aws-k8s/commit/cbdeecbf5c1c62358f647be05af1ef77a0197dab))
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.105.0 ([#240](https://github.com/opzkit/terraform-aws-k8s/issues/240)) ([019530d](https://github.com/opzkit/terraform-aws-k8s/commit/019530dd93ae635de2a666d0624394aa892fb1ec))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v42.71.0 ([#239](https://github.com/opzkit/terraform-aws-k8s/issues/239)) ([7259b38](https://github.com/opzkit/terraform-aws-k8s/commit/7259b38673c1231475ad21d246a75dd6df360a9c))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v42.78.1 ([#241](https://github.com/opzkit/terraform-aws-k8s/issues/241)) ([5a06d70](https://github.com/opzkit/terraform-aws-k8s/commit/5a06d70ae0d9603336eae9e472c275b428d7969b))

## [0.25.0](https://github.com/opzkit/terraform-aws-k8s/compare/v0.24.1...v0.25.0) (2026-01-01)


### Features

* add zones field for AZ selection in additional node groups ([#234](https://github.com/opzkit/terraform-aws-k8s/issues/234)) ([5d1bbd7](https://github.com/opzkit/terraform-aws-k8s/commit/5d1bbd748250cc1a1c84fa4e7f7cb5fe0ad15a4f))


### Bug Fixes

* use coalesce to handle null zones in additional_nodes ([#236](https://github.com/opzkit/terraform-aws-k8s/issues/236)) ([cdba27f](https://github.com/opzkit/terraform-aws-k8s/commit/cdba27f403e3f82fd0ee04fc8ab9bbbe8e276064))


### Miscellaneous Chores

* **deps:** update actions/checkout action to v6.0.1 ([#228](https://github.com/opzkit/terraform-aws-k8s/issues/228)) ([58779e0](https://github.com/opzkit/terraform-aws-k8s/commit/58779e0d37e8c0535590c7989a8e99b84ff9af4e))
* **deps:** update actions/checkout digest to 8e8c483 ([#227](https://github.com/opzkit/terraform-aws-k8s/issues/227)) ([adbca2b](https://github.com/opzkit/terraform-aws-k8s/commit/adbca2b6229300842b89b0166df69cec0b817181))
* **deps:** update actions/create-github-app-token digest to 29824e6 ([#229](https://github.com/opzkit/terraform-aws-k8s/issues/229)) ([bb4e0bf](https://github.com/opzkit/terraform-aws-k8s/commit/bb4e0bf8a5f98bc981e0e691bb82dccd463b1eca))
* **deps:** update default-request-adder to v1.2.3 ([#231](https://github.com/opzkit/terraform-aws-k8s/issues/231)) ([4333e5f](https://github.com/opzkit/terraform-aws-k8s/commit/4333e5f668052d6894b20ba864b45ca28a0ea690))
* **deps:** update default-request-adder to v1.2.4 ([#232](https://github.com/opzkit/terraform-aws-k8s/issues/232)) ([3b2b48c](https://github.com/opzkit/terraform-aws-k8s/commit/3b2b48c2f5b5012adba0a172c44bf9021ef49fdb))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v42.27.0 ([#225](https://github.com/opzkit/terraform-aws-k8s/issues/225)) ([851baeb](https://github.com/opzkit/terraform-aws-k8s/commit/851baebc25777f388807bc0205114a7df9e8a16a))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v42.39.2 ([#230](https://github.com/opzkit/terraform-aws-k8s/issues/230)) ([bb934eb](https://github.com/opzkit/terraform-aws-k8s/commit/bb934ebe5b3a620121c409638a5a0e73f5bb21f0))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v42.64.1 ([#233](https://github.com/opzkit/terraform-aws-k8s/issues/233)) ([f0392ca](https://github.com/opzkit/terraform-aws-k8s/commit/f0392ca84c5b63f9b10675da16a1b69ce2356630))

## [0.24.1](https://github.com/opzkit/terraform-aws-k8s/compare/v0.24.0...v0.24.1) (2025-11-28)


### Miscellaneous Chores

* **deps:** update actions/setup-python action to v6.1.0 ([#223](https://github.com/opzkit/terraform-aws-k8s/issues/223)) ([88c29c8](https://github.com/opzkit/terraform-aws-k8s/commit/88c29c841acc76c98bf9f8c0b8f5bada1b98efcc))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v42.19.3 ([#221](https://github.com/opzkit/terraform-aws-k8s/issues/221)) ([a0a2fc9](https://github.com/opzkit/terraform-aws-k8s/commit/a0a2fc9896a7f832bd974fa1903a5e3ba4f3be61))
* **deps:** update terraform github.com/opzkit/terraform-aws-k8s-addons-cluster-autoscaler to v1.34.2 ([#224](https://github.com/opzkit/terraform-aws-k8s/issues/224)) ([e3b2ee0](https://github.com/opzkit/terraform-aws-k8s/commit/e3b2ee076b42321903bdc2feb2ae911b1face70d))

## [0.24.0](https://github.com/opzkit/terraform-aws-k8s/compare/v0.23.1...v0.24.0) (2025-11-22)


### Features

* enable Prometheus metrics for Cilium ([#216](https://github.com/opzkit/terraform-aws-k8s/issues/216)) ([16f67ce](https://github.com/opzkit/terraform-aws-k8s/commit/16f67ce32ff43d68c2ec86b196c114b285f641cd))


### Miscellaneous Chores

* **deps:** update actions/checkout action to v6 ([#219](https://github.com/opzkit/terraform-aws-k8s/issues/219)) ([33d3df7](https://github.com/opzkit/terraform-aws-k8s/commit/33d3df775ab01f1982f4b1df7179d10a220a3596))
* **deps:** update actions/create-github-app-token digest to 7e473ef ([#220](https://github.com/opzkit/terraform-aws-k8s/issues/220)) ([0213d49](https://github.com/opzkit/terraform-aws-k8s/commit/0213d498db8a80f0caff0572acc25733673ef1f9))
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.104.0 ([#218](https://github.com/opzkit/terraform-aws-k8s/issues/218)) ([70b8447](https://github.com/opzkit/terraform-aws-k8s/commit/70b8447f207af6d67da5e3e335069e64743869cd))

## [0.23.1](https://github.com/opzkit/terraform-aws-k8s/compare/v0.23.0...v0.23.1) (2025-11-18)


### Bug Fixes

* update precondition logic for subnet zone checks ([#215](https://github.com/opzkit/terraform-aws-k8s/issues/215)) ([6d17a07](https://github.com/opzkit/terraform-aws-k8s/commit/6d17a072f6fa3aecd8813217b2ec228f895fd6fb))


### Miscellaneous Chores

* **deps:** update actions/checkout action to v5.0.1 ([#213](https://github.com/opzkit/terraform-aws-k8s/issues/213)) ([8987047](https://github.com/opzkit/terraform-aws-k8s/commit/8987047662f5f2f6181a23a732afdf2bb8cb319f))
* **deps:** update actions/checkout digest to 93cb6ef ([#212](https://github.com/opzkit/terraform-aws-k8s/issues/212)) ([62680f9](https://github.com/opzkit/terraform-aws-k8s/commit/62680f99e2af06b2b2c82e96b99258905527268e))

## [0.23.0](https://github.com/opzkit/terraform-aws-k8s/compare/v0.22.0...v0.23.0) (2025-11-17)


### Features

* **k8s:** add node-role labels for better categorization ([#210](https://github.com/opzkit/terraform-aws-k8s/issues/210)) ([e8c3ea7](https://github.com/opzkit/terraform-aws-k8s/commit/e8c3ea703c9ee67bdf26018b60a57bde6fa8862e))
* **k8s:** refactor instance group configuration and settings ([#211](https://github.com/opzkit/terraform-aws-k8s/issues/211)) ([ae4995f](https://github.com/opzkit/terraform-aws-k8s/commit/ae4995f7f8015b7886b0acf74403a335c372b8db))


### Miscellaneous Chores

* **automerge:** integrate GitHub app token for auto-merge ([#207](https://github.com/opzkit/terraform-aws-k8s/issues/207)) ([ed66f69](https://github.com/opzkit/terraform-aws-k8s/commit/ed66f693afc56424de775c8694290ba886d097d8))
* **deps:** update default-request-adder to v1.2.2 ([#208](https://github.com/opzkit/terraform-aws-k8s/issues/208)) ([2b542aa](https://github.com/opzkit/terraform-aws-k8s/commit/2b542aa83abec954fe6fbaee56017274430f8abc))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.173.1 ([#205](https://github.com/opzkit/terraform-aws-k8s/issues/205)) ([16d0767](https://github.com/opzkit/terraform-aws-k8s/commit/16d0767a5112efb84f762badb96c6d8f4df07bbd))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v42 ([#206](https://github.com/opzkit/terraform-aws-k8s/issues/206)) ([d916786](https://github.com/opzkit/terraform-aws-k8s/commit/d916786c4b04870ea42c9988f5036e01ab1cca62))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v42.11.0 ([#209](https://github.com/opzkit/terraform-aws-k8s/issues/209)) ([6ed63b1](https://github.com/opzkit/terraform-aws-k8s/commit/6ed63b1e67a3108cacd93c31f8a54383074e8e44))
* **deps:** update terraform-linters/setup-tflint action to v6.2.1 ([#203](https://github.com/opzkit/terraform-aws-k8s/issues/203)) ([5cce1a1](https://github.com/opzkit/terraform-aws-k8s/commit/5cce1a1826530d0b516aa61ee057f195b334bf4b))

## [0.22.0](https://github.com/opzkit/terraform-aws-k8s/compare/v0.21.2...v0.22.0) (2025-10-29)


### Features

* add private and public subnet variables with validation ([#201](https://github.com/opzkit/terraform-aws-k8s/issues/201)) ([54cc189](https://github.com/opzkit/terraform-aws-k8s/commit/54cc189904a784f26f202e592bc71720d4175aba))
* k8s-cilium-kubeproxy-update ([#200](https://github.com/opzkit/terraform-aws-k8s/issues/200)) ([2a0453c](https://github.com/opzkit/terraform-aws-k8s/commit/2a0453c342e5aceffc24f42ed89cf72df5d90595))
* update subnet handling based on environment type ([#202](https://github.com/opzkit/terraform-aws-k8s/issues/202)) ([d3ce1cb](https://github.com/opzkit/terraform-aws-k8s/commit/d3ce1cb7feabd96264e10782717386eaf1859dbd))


### Miscellaneous Chores

* **deps:** update googleapis/release-please-action digest to 16a9c90 ([#198](https://github.com/opzkit/terraform-aws-k8s/issues/198)) ([c6bff6e](https://github.com/opzkit/terraform-aws-k8s/commit/c6bff6e2d421d2baeb06b166d356277fa16ca1e6))

## [0.21.2](https://github.com/opzkit/terraform-aws-k8s/compare/v0.21.1...v0.21.2) (2025-10-23)


### Code Refactoring

* remove unused cluster_name variable ([#196](https://github.com/opzkit/terraform-aws-k8s/issues/196)) ([4e7f2e8](https://github.com/opzkit/terraform-aws-k8s/commit/4e7f2e8994b51408349d4a1151c804056bd3890e))

## [0.21.1](https://github.com/opzkit/terraform-aws-k8s/compare/v0.21.0...v0.21.1) (2025-10-22)


### Bug Fixes

* **aws:** update AMI name regex for Ubuntu 24.04 ([#195](https://github.com/opzkit/terraform-aws-k8s/issues/195)) ([675db82](https://github.com/opzkit/terraform-aws-k8s/commit/675db8273792b9e229085b64e22b6eb676c923e5))


### Miscellaneous Chores

* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.102.0 ([#190](https://github.com/opzkit/terraform-aws-k8s/issues/190)) ([ca69d09](https://github.com/opzkit/terraform-aws-k8s/commit/ca69d09d5aee07c3f79df566654df7304235f4f6))
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.103.0 ([#194](https://github.com/opzkit/terraform-aws-k8s/issues/194)) ([bb47613](https://github.com/opzkit/terraform-aws-k8s/commit/bb47613ca1e778cccf7fe43f8e36c61cf30afb0e))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.144.0 ([#181](https://github.com/opzkit/terraform-aws-k8s/issues/181)) ([44331ee](https://github.com/opzkit/terraform-aws-k8s/commit/44331ee17bc0991c4a31dfaed4d9fde169236c2a))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.144.1 ([#183](https://github.com/opzkit/terraform-aws-k8s/issues/183)) ([143b48d](https://github.com/opzkit/terraform-aws-k8s/commit/143b48df97bb1ec44a414815bf91fb67494bc395))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.144.3 ([#184](https://github.com/opzkit/terraform-aws-k8s/issues/184)) ([f74d77d](https://github.com/opzkit/terraform-aws-k8s/commit/f74d77df09d0e95b39d69621c71085a994f9beca))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.144.4 ([#185](https://github.com/opzkit/terraform-aws-k8s/issues/185)) ([0823a89](https://github.com/opzkit/terraform-aws-k8s/commit/0823a89e758a9bc6f3868aa2ede750d574485355))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.145.1 ([#186](https://github.com/opzkit/terraform-aws-k8s/issues/186)) ([28024c0](https://github.com/opzkit/terraform-aws-k8s/commit/28024c0cc81fd4704646d524aab933346c19b1ba))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.145.3 ([#187](https://github.com/opzkit/terraform-aws-k8s/issues/187)) ([72f9b22](https://github.com/opzkit/terraform-aws-k8s/commit/72f9b22a0066f3852a9fab9e2eb2e31490d5a5b1))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.146.0 ([#188](https://github.com/opzkit/terraform-aws-k8s/issues/188)) ([a398d38](https://github.com/opzkit/terraform-aws-k8s/commit/a398d3895b1bddcb17f619b25a7b7750a90c96d8))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.148.6 ([#191](https://github.com/opzkit/terraform-aws-k8s/issues/191)) ([737f242](https://github.com/opzkit/terraform-aws-k8s/commit/737f242c35b4d252ae28d6d4d913ed1a7761416d))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.149.2 ([#192](https://github.com/opzkit/terraform-aws-k8s/issues/192)) ([d73e3be](https://github.com/opzkit/terraform-aws-k8s/commit/d73e3be87b097bf14eab4e46fc5643c7f2a79893))


### Continuous Integration

* add daily schedule for Renovate pre-commit hook updates ([#189](https://github.com/opzkit/terraform-aws-k8s/issues/189)) ([52bf89a](https://github.com/opzkit/terraform-aws-k8s/commit/52bf89a9f2050e31186afffa80063c0f977b0ca0))
* remove unnecessary Renovate schedule configuration ([#193](https://github.com/opzkit/terraform-aws-k8s/issues/193)) ([e1fe217](https://github.com/opzkit/terraform-aws-k8s/commit/e1fe2170e374494b4cbb5cadfdbc1a81c6db0a6b))

## [0.21.0](https://github.com/opzkit/terraform-aws-k8s/compare/v0.20.1...v0.21.0) (2025-10-09)


### Features

* **k8s:** add containerd configuration support ([#179](https://github.com/opzkit/terraform-aws-k8s/issues/179)) ([246b237](https://github.com/opzkit/terraform-aws-k8s/commit/246b23748b81c8cc138d159bc6d668251138b67d))


### Miscellaneous Chores

* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.101.1 ([#177](https://github.com/opzkit/terraform-aws-k8s/issues/177)) ([47b2145](https://github.com/opzkit/terraform-aws-k8s/commit/47b21452dd1b511d6a0af4d196134440dcfa4309))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.143.2 ([#180](https://github.com/opzkit/terraform-aws-k8s/issues/180)) ([14ba3a8](https://github.com/opzkit/terraform-aws-k8s/commit/14ba3a8236cfa1de41a5edfaca63b3962a2cfa10))

## [0.20.1](https://github.com/opzkit/terraform-aws-k8s/compare/v0.20.0...v0.20.1) (2025-10-09)


### Miscellaneous Chores

* add renovate pre-commit check ([#156](https://github.com/opzkit/terraform-aws-k8s/issues/156)) ([2e08870](https://github.com/opzkit/terraform-aws-k8s/commit/2e08870e8f831e1ed0a85bdf0803c96c6b32b73b))
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.23.0 ([#158](https://github.com/opzkit/terraform-aws-k8s/issues/158)) ([65e6b0e](https://github.com/opzkit/terraform-aws-k8s/commit/65e6b0ea2d07243216a769405907065a076ddeac))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.135.3 ([#161](https://github.com/opzkit/terraform-aws-k8s/issues/161)) ([b27dd60](https://github.com/opzkit/terraform-aws-k8s/commit/b27dd6035e2f74e301ab3db70c757c1dfbb1ff39))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.135.4 ([#162](https://github.com/opzkit/terraform-aws-k8s/issues/162)) ([e1458f6](https://github.com/opzkit/terraform-aws-k8s/commit/e1458f6bca57052a592f99c725d0deba3c9bd8c3))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.135.5 ([#163](https://github.com/opzkit/terraform-aws-k8s/issues/163)) ([b2ea344](https://github.com/opzkit/terraform-aws-k8s/commit/b2ea344beafc325db6a4e73760872ba74200711b))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.136.0 ([#164](https://github.com/opzkit/terraform-aws-k8s/issues/164)) ([69a08ca](https://github.com/opzkit/terraform-aws-k8s/commit/69a08ca959bf64479794d0ae8e1f23326086d522))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.137.1 ([#165](https://github.com/opzkit/terraform-aws-k8s/issues/165)) ([27918c3](https://github.com/opzkit/terraform-aws-k8s/commit/27918c393cf62e5d55c3f556753b094192be431e))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.138.0 ([#166](https://github.com/opzkit/terraform-aws-k8s/issues/166)) ([3e91def](https://github.com/opzkit/terraform-aws-k8s/commit/3e91def63ed7966d9e48ff1e739916d6230bad24))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.138.1 ([#168](https://github.com/opzkit/terraform-aws-k8s/issues/168)) ([7384dbc](https://github.com/opzkit/terraform-aws-k8s/commit/7384dbc5eb53dd6f531b016d243ed5916f6c3e81))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.138.4 ([#169](https://github.com/opzkit/terraform-aws-k8s/issues/169)) ([a45e63e](https://github.com/opzkit/terraform-aws-k8s/commit/a45e63ea1df699880dc974e771a26dc3fe984755))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.138.5 ([#170](https://github.com/opzkit/terraform-aws-k8s/issues/170)) ([c5d607e](https://github.com/opzkit/terraform-aws-k8s/commit/c5d607e031672b8dd429b61576ed463effad1c9c))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.139.0 ([#171](https://github.com/opzkit/terraform-aws-k8s/issues/171)) ([df5ec87](https://github.com/opzkit/terraform-aws-k8s/commit/df5ec870d68ab6a12c57b9217c9d23dc83c4a39b))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.140.2 ([#172](https://github.com/opzkit/terraform-aws-k8s/issues/172)) ([b0bf945](https://github.com/opzkit/terraform-aws-k8s/commit/b0bf94561908aed9c4cb203afebe1c37712585af))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.141.0 ([#173](https://github.com/opzkit/terraform-aws-k8s/issues/173)) ([e22a189](https://github.com/opzkit/terraform-aws-k8s/commit/e22a189afc0a19ee7cedd5a07964b8451c942ba9))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.143.0 ([#174](https://github.com/opzkit/terraform-aws-k8s/issues/174)) ([36d2f42](https://github.com/opzkit/terraform-aws-k8s/commit/36d2f4224085a73127c85a04a6a1a5468b6f77e8))
* **deps:** update pre-commit hook renovatebot/pre-commit-hooks to v41.143.1 ([#175](https://github.com/opzkit/terraform-aws-k8s/issues/175)) ([d87c110](https://github.com/opzkit/terraform-aws-k8s/commit/d87c110e2e992f415150b1f02dfeb9e51467dc98))
* **deps:** update terraform github.com/opzkit/terraform-aws-k8s-addons-cluster-autoscaler to v1.34.1 ([#176](https://github.com/opzkit/terraform-aws-k8s/issues/176)) ([07a5a94](https://github.com/opzkit/terraform-aws-k8s/commit/07a5a9433c071d6845385024f442ad75a91b1ed7))
* **deps:** update terraform-linters/setup-tflint action to v6 ([#159](https://github.com/opzkit/terraform-aws-k8s/issues/159)) ([2ab6702](https://github.com/opzkit/terraform-aws-k8s/commit/2ab6702f7b942f022eee8748547c532e16ac61a7))
* **deps:** update terraform-linters/setup-tflint action to v6.1.0 ([#160](https://github.com/opzkit/terraform-aws-k8s/issues/160)) ([e71ef16](https://github.com/opzkit/terraform-aws-k8s/commit/e71ef16b5cd614387bc672c3657319e5d039fbfa))
* **deps:** update terraform-linters/setup-tflint action to v6.2.0 ([#167](https://github.com/opzkit/terraform-aws-k8s/issues/167)) ([c08b18e](https://github.com/opzkit/terraform-aws-k8s/commit/c08b18e124321446b935e48c4ac8f47d365cda06))

## [0.20.0](https://github.com/opzkit/terraform-aws-k8s/compare/v0.19.5...v0.20.0) (2025-10-01)


### Features

* add default_request_adder with excluded namespaces ([#146](https://github.com/opzkit/terraform-aws-k8s/issues/146)) ([47d6212](https://github.com/opzkit/terraform-aws-k8s/commit/47d6212aeeb75c989848be38f68183c783acef0a))
* add package rules for default-request-adder grouping ([#154](https://github.com/opzkit/terraform-aws-k8s/issues/154)) ([f34e71f](https://github.com/opzkit/terraform-aws-k8s/commit/f34e71f583bd836923258db70dc0f36f5ded0d4d))


### Bug Fixes

* correct regex pattern for kubernetes managerFilePatterns ([#148](https://github.com/opzkit/terraform-aws-k8s/issues/148)) ([8d277d3](https://github.com/opzkit/terraform-aws-k8s/commit/8d277d3250c905781d8b242aeae098e3a11050b4))
* update version and file references for default request adder ([#150](https://github.com/opzkit/terraform-aws-k8s/issues/150)) ([f52e2f6](https://github.com/opzkit/terraform-aws-k8s/commit/f52e2f64c35a24c013d78014450033143c84bd38))


### Miscellaneous Chores

* **deps:** pin registry.gitlab.com/unboundsoftware/default-request-adder docker tag to 1a57dce ([#149](https://github.com/opzkit/terraform-aws-k8s/issues/149)) ([a932c8e](https://github.com/opzkit/terraform-aws-k8s/commit/a932c8ee6a30cf2c171c8a1fed3f0b355ee306be))
* **deps:** pin registry.gitlab.com/unboundsoftware/default-request-adder docker tag to 9eb0a0e ([#151](https://github.com/opzkit/terraform-aws-k8s/issues/151)) ([23d5ed0](https://github.com/opzkit/terraform-aws-k8s/commit/23d5ed0191e9b6e5ceeedc3079d2d676b4a76fcd))
* **deps:** update default-request-adder to v1.2.1 ([#155](https://github.com/opzkit/terraform-aws-k8s/issues/155)) ([d0b8114](https://github.com/opzkit/terraform-aws-k8s/commit/d0b811415f719f037cd91f6ccd1ae138a57d895a))
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.100.1 ([#143](https://github.com/opzkit/terraform-aws-k8s/issues/143)) ([8e4e1cd](https://github.com/opzkit/terraform-aws-k8s/commit/8e4e1cd9e12b8d5fb3c36585e0b286b5e299c3ed))
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.101.0 ([#145](https://github.com/opzkit/terraform-aws-k8s/issues/145)) ([2dd709a](https://github.com/opzkit/terraform-aws-k8s/commit/2dd709afa382ab41159e7781b98738b6a380c2a5))


### Continuous Integration

* add custom manager for regex version updates ([#147](https://github.com/opzkit/terraform-aws-k8s/issues/147)) ([694b516](https://github.com/opzkit/terraform-aws-k8s/commit/694b5164069fdac118cbf7d285e70f708edf0777))

## [0.19.5](https://github.com/opzkit/terraform-aws-k8s/compare/v0.19.4...v0.19.5) (2025-09-15)


### Bug Fixes

* update cluster autoscaler module source version ([#140](https://github.com/opzkit/terraform-aws-k8s/issues/140)) ([2c4d158](https://github.com/opzkit/terraform-aws-k8s/commit/2c4d158ef5102fa9b778ca6c8d83337c00aa80eb))


### Miscellaneous Chores

* **commitlint:** increase header max length to 105 chars ([#142](https://github.com/opzkit/terraform-aws-k8s/issues/142)) ([e7ca927](https://github.com/opzkit/terraform-aws-k8s/commit/e7ca927a14216ee3dbd090379caf295ff0b717e9))
* **deps:** update actions/create-github-app-token digest to 6701853 ([#138](https://github.com/opzkit/terraform-aws-k8s/issues/138)) ([73ea1d9](https://github.com/opzkit/terraform-aws-k8s/commit/73ea1d9dabadba05df45fd77f56f8f0d188c7714))
* **deps:** update terraform github.com/opzkit/terraform-aws-k8s-addons-cluster-autoscaler to v1.34.0 ([#141](https://github.com/opzkit/terraform-aws-k8s/issues/141)) ([0a7dccf](https://github.com/opzkit/terraform-aws-k8s/commit/0a7dccfd9ebd264313aad265cac5a6bb27bfce31))

## [0.19.4](https://github.com/opzkit/terraform-aws-k8s/compare/v0.19.3...v0.19.4) (2025-09-13)


### Bug Fixes

* **cluster_autoscaler:** update module version to v1.33.2 ([#137](https://github.com/opzkit/terraform-aws-k8s/issues/137)) ([59bf3a5](https://github.com/opzkit/terraform-aws-k8s/commit/59bf3a5b5f0067c15eeb607e7a30b1d9173bbc8c))


### Miscellaneous Chores

* **deps:** update actions/checkout action to v4.3.0 ([#131](https://github.com/opzkit/terraform-aws-k8s/issues/131)) ([31a1553](https://github.com/opzkit/terraform-aws-k8s/commit/31a1553f56d3b982e13464ced7a8ec95c86417c6))
* **deps:** update actions/checkout action to v5 ([#132](https://github.com/opzkit/terraform-aws-k8s/issues/132)) ([59be62b](https://github.com/opzkit/terraform-aws-k8s/commit/59be62bec141e21aa249898163245769d5dc49aa))
* **deps:** update actions/checkout digest to 08eba0b ([#130](https://github.com/opzkit/terraform-aws-k8s/issues/130)) ([fe057b0](https://github.com/opzkit/terraform-aws-k8s/commit/fe057b006c8e04e61b6d04128ecc18c863122f36))
* **deps:** update actions/setup-python action to v6 ([#136](https://github.com/opzkit/terraform-aws-k8s/issues/136)) ([23dc8b9](https://github.com/opzkit/terraform-aws-k8s/commit/23dc8b976680eab20f45ca57af4a9540b72e8b19))
* **deps:** update googleapis/release-please-action digest to c2a5a2b ([#135](https://github.com/opzkit/terraform-aws-k8s/issues/135)) ([61acf68](https://github.com/opzkit/terraform-aws-k8s/commit/61acf6858463fb92205fea6328941b2bb69051e8))
* **deps:** update pre-commit hook pre-commit/pre-commit-hooks to v6 ([#128](https://github.com/opzkit/terraform-aws-k8s/issues/128)) ([5c223d1](https://github.com/opzkit/terraform-aws-k8s/commit/5c223d1e4e966238507d423c4ac6cd463c9b57bc))
* **deps:** update terraform-linters/setup-tflint action to v5 ([#133](https://github.com/opzkit/terraform-aws-k8s/issues/133)) ([3fa4be0](https://github.com/opzkit/terraform-aws-k8s/commit/3fa4be0ef67ac221e2ec97c2137eeff576770491))


### Continuous Integration

* add GitHub Actions workflow for release automation ([#134](https://github.com/opzkit/terraform-aws-k8s/issues/134)) ([d6fdf13](https://github.com/opzkit/terraform-aws-k8s/commit/d6fdf13963951e488e893b54f7e5c65c92c53fab))

## [0.19.3](https://github.com/opzkit/terraform-aws-k8s/compare/v0.19.2...v0.19.3) (2025-08-08)


### Bug Fixes

* **k8s:** add additional nodes to cluster updater dependencies ([#126](https://github.com/opzkit/terraform-aws-k8s/issues/126)) ([1763167](https://github.com/opzkit/terraform-aws-k8s/commit/176316748a5e94e9926c63079a81b279e3cc52b3))


### Miscellaneous Chores

* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.100.0 ([#127](https://github.com/opzkit/terraform-aws-k8s/issues/127)) ([f5512e1](https://github.com/opzkit/terraform-aws-k8s/commit/f5512e143eec1e77b8597298d85b53941c565947))
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.99.5 ([#124](https://github.com/opzkit/terraform-aws-k8s/issues/124)) ([39bc409](https://github.com/opzkit/terraform-aws-k8s/commit/39bc4091b213458461dc58873022137e832088b4))

## [0.19.2](https://github.com/opzkit/terraform-aws-k8s/compare/v0.19.1...v0.19.2) (2025-06-19)


### Miscellaneous Chores

* **deps:** update actions/setup-python action to v5.6.0 ([#117](https://github.com/opzkit/terraform-aws-k8s/issues/117)) ([38f92e2](https://github.com/opzkit/terraform-aws-k8s/commit/38f92e28806984bfd1b0a2b77e0292cf9a2aad21))
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.99.0 ([#115](https://github.com/opzkit/terraform-aws-k8s/issues/115)) ([f6e4b31](https://github.com/opzkit/terraform-aws-k8s/commit/f6e4b3144a7428283cca5b9bf4f61576d951816e))
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.99.1 ([#120](https://github.com/opzkit/terraform-aws-k8s/issues/120)) ([b52ee72](https://github.com/opzkit/terraform-aws-k8s/commit/b52ee7253463f76fb1c61b5abefd3027696421a2))
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.99.3 ([#121](https://github.com/opzkit/terraform-aws-k8s/issues/121)) ([daef3a2](https://github.com/opzkit/terraform-aws-k8s/commit/daef3a2d44373c589c59d66e2e5ed5accf379fc7))
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.99.4 ([#122](https://github.com/opzkit/terraform-aws-k8s/issues/122)) ([117080b](https://github.com/opzkit/terraform-aws-k8s/commit/117080bc8be7822d4dfc2e9b4b349ba82a86c227))
* **deps:** update terraform aws to v6 ([#123](https://github.com/opzkit/terraform-aws-k8s/issues/123)) ([418b9e6](https://github.com/opzkit/terraform-aws-k8s/commit/418b9e63c9e27ac9a495dca3b552d38d8aca2e2f))
* remove unnecessary work flow for release please ([#118](https://github.com/opzkit/terraform-aws-k8s/issues/118)) ([06eb901](https://github.com/opzkit/terraform-aws-k8s/commit/06eb901e3923208cd31e79b8042f11ce44e2c41b))

## [0.19.1](https://github.com/opzkit/terraform-aws-k8s/compare/v0.19.0...v0.19.1) (2025-04-10)


### Miscellaneous Chores

* update required version and Kubernetes version ([#113](https://github.com/opzkit/terraform-aws-k8s/issues/113)) ([8dd7a3c](https://github.com/opzkit/terraform-aws-k8s/commit/8dd7a3c5542aec8385eb08b095b1abe6e7dd52a8))

## [0.19.0](https://github.com/opzkit/terraform-aws-k8s/compare/v0.18.4...v0.19.0) (2025-04-09)


### Features

* refactor K8s resources and improve CI configuration ([#111](https://github.com/opzkit/terraform-aws-k8s/issues/111)) ([bca3c42](https://github.com/opzkit/terraform-aws-k8s/commit/bca3c42308f7f2d2a6ddc66bdb32e54c3cb7a6de))


### Miscellaneous Chores

* Configure Renovate ([154af0d](https://github.com/opzkit/terraform-aws-k8s/commit/154af0d360abad6ca0fc97eea337d886754a5d5a))
* **deps:** add renovate.json ([ef60280](https://github.com/opzkit/terraform-aws-k8s/commit/ef60280ae69ceaa29107feedb3a38ebc7884184f))
* **deps:** pin dependencies ([#109](https://github.com/opzkit/terraform-aws-k8s/issues/109)) ([f8cd24b](https://github.com/opzkit/terraform-aws-k8s/commit/f8cd24bbe1f4c6993a1e554393a5807f55600a01))
* update pre-commit flow ([#112](https://github.com/opzkit/terraform-aws-k8s/issues/112)) ([11e3ae1](https://github.com/opzkit/terraform-aws-k8s/commit/11e3ae15622eb93f9d53f07ed3d0ee6d0b20e8db))

## [0.18.4](https://github.com/opzkit/terraform-aws-k8s/compare/v0.18.3...v0.18.4) (2025-03-14)


### Code Refactoring

* update label to use standardized naming convention ([3523c40](https://github.com/opzkit/terraform-aws-k8s/commit/3523c400c00ebc51d0f28a32f2a8859a4eb07595))

## [0.18.3](https://github.com/opzkit/terraform-aws-k8s/compare/v0.18.2...v0.18.3) (2025-02-04)


### Miscellaneous Chores

* **dependabot:** simplify terraform directories configuration ([52241fd](https://github.com/opzkit/terraform-aws-k8s/commit/52241fd6d20426ac72eeacba253feeb931fccdd1))
* **deps:** bump terraform-kops/kops from 1.30.4 to 1.31.0 ([904baeb](https://github.com/opzkit/terraform-aws-k8s/commit/904baeb7b8a558039988c17e8a9f05af5d35f40f))

## [0.18.2](https://github.com/opzkit/terraform-aws-k8s/compare/v0.18.1...v0.18.2) (2025-02-03)


### Miscellaneous Chores

* **deps:** bump terraform-kops/kops from 1.30.3 to 1.30.4 ([4431b3b](https://github.com/opzkit/terraform-aws-k8s/commit/4431b3bddb92ee33095e7062aa0ef909444a333a))

## [0.18.1](https://github.com/opzkit/terraform-aws-k8s/compare/v0.18.0...v0.18.1) (2025-01-28)


### Miscellaneous Chores

* **deps:** bump terraform-kops/kops from 1.30.1 to 1.30.3 ([31b7de2](https://github.com/opzkit/terraform-aws-k8s/commit/31b7de23f7b8aabe875954c09fab688f3b2b66c8))

## [0.18.0](https://github.com/opzkit/terraform-aws-k8s/compare/v0.17.0...v0.18.0) (2024-09-23)


### Features

* update kops provider version to 1.30.1 ([18e33a4](https://github.com/opzkit/terraform-aws-k8s/commit/18e33a4644418cf3710c89d31eb5d076dc9fc8c2))


### Miscellaneous Chores

* update cluster autoscaler module version ([f2db175](https://github.com/opzkit/terraform-aws-k8s/commit/f2db175481cda02a6c9d7620edd84007bafcea6b))

## [0.17.0](https://github.com/opzkit/terraform-aws-k8s/compare/v0.16.1...v0.17.0) (2024-09-11)


### Features

* update kOps provider version to 1.30.0 ([04786cf](https://github.com/opzkit/terraform-aws-k8s/commit/04786cf1d1e668c8e7e4a1fbe3bfa9ae0d47076e))

## [0.16.1](https://github.com/opzkit/terraform-aws-k8s/compare/v0.16.0...v0.16.1) (2024-08-21)


### Bug Fixes

* add delete block in cluster config ([bd09078](https://github.com/opzkit/terraform-aws-k8s/commit/bd09078fbd383667ceef9122e816693496a9fd9f))

## [0.16.0](https://github.com/opzkit/terraform-aws-k8s/compare/v0.15.1...v0.16.0) (2024-08-21)


### Features

* disable kubelet anonymous auth ([93adf2c](https://github.com/opzkit/terraform-aws-k8s/commit/93adf2c2b15fa76b0659444d50d541d54ded71e0))
* update kops provider version to 1.29.0 ([82f3cd3](https://github.com/opzkit/terraform-aws-k8s/commit/82f3cd35ccd95b244804edda28edbb6d8b81d667))


### Continuous Integration

* fix typo in changelog section type ([a284d13](https://github.com/opzkit/terraform-aws-k8s/commit/a284d13dec36a0fda16e3bb65cf639886eb68697))

## [0.15.1](https://github.com/opzkit/terraform-aws-k8s/compare/v0.15.0...v0.15.1) (2024-08-14)


### Bug Fixes

* add namespace to default ingress ([7b9248d](https://github.com/opzkit/terraform-aws-k8s/commit/7b9248dca347c7d4f952e28a7a9c528005e6edd0))
* remove namespace from cluster scoped role/binding ([0af2b26](https://github.com/opzkit/terraform-aws-k8s/commit/0af2b261d6d44926f1261e2013e8a9a75e0277f1))


### Miscellaneous Chores

* disable unwanted checks ([032156b](https://github.com/opzkit/terraform-aws-k8s/commit/032156b74c63769c5da3a9afecd87958641b2a83))
* github action default permission ([ff3d4da](https://github.com/opzkit/terraform-aws-k8s/commit/ff3d4dac4129035b5b3916e7a626867ef9b4ee00))
* rename default-ingress to alb-ssl-ingress ([7bdaf24](https://github.com/opzkit/terraform-aws-k8s/commit/7bdaf2457bad0b1effe3ceb8bc8ca097101b6eb5))
* show all sections in change log ([60053b7](https://github.com/opzkit/terraform-aws-k8s/commit/60053b7c5dce899932dfbc0edaef37fa822047aa))

## [0.15.0](https://github.com/opzkit/terraform-aws-k8s/compare/v0.14.4...v0.15.0) (2024-07-17)


### Features

* support changing architecture for nodes ([11c13c9](https://github.com/opzkit/terraform-aws-k8s/commit/11c13c967b5847e200a6e7d3b180df050d81f37e))
