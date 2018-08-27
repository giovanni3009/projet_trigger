-- phpMyAdmin SQL Dump
-- version 4.6.4
-- https://www.phpmyadmin.net/
--
-- Client :  127.0.0.1
-- Généré le :  Ven 24 Août 2018 à 02:26
-- Version du serveur :  5.7.14
-- Version de PHP :  5.6.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données :  `projet_triggers_m2`
--

-- --------------------------------------------------------

--
-- Structure de la table `admin`
--

CREATE TABLE `admin` (
  `Id_adm` int(4) NOT NULL,
  `pseudo` varchar(45) NOT NULL,
  `mdp` int(120) NOT NULL,
  `type` int(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `recettes_historique`
--

CREATE TABLE `recettes_historique` (
  `vd_id` int(11) NOT NULL,
  `recette_derniere_mod_dt` datetime NOT NULL,
  `rc_montant` decimal(12,2) DEFAULT NULL,
  `recette_dernieremod_bd_user` varchar(255) NOT NULL,
  `recette_derniermod_user_id` int(11) DEFAULT NULL,
  `evenement_histo` char(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `recettes_historique`
--

INSERT INTO `recettes_historique` (`vd_id`, `recette_derniere_mod_dt`, `rc_montant`, `recette_dernieremod_bd_user`, `recette_derniermod_user_id`, `evenement_histo`) VALUES
(2, '2018-07-01 19:37:45', '400000.00', 'root@localhost', NULL, 'UPDATE'),
(2, '2018-07-01 19:47:43', '600000.00', 'root@localhost', NULL, 'DELETE');

-- --------------------------------------------------------

--
-- Structure de la table `recettes_jour`
--

CREATE TABLE `recettes_jour` (
  `rc_date` date NOT NULL,
  `rc_montant` decimal(12,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `recettes_jour`
--

INSERT INTO `recettes_jour` (`rc_date`, `rc_montant`) VALUES
('2018-07-01', '400000.00');

-- --------------------------------------------------------

--
-- Structure de la table `recettes_mois`
--

CREATE TABLE `recettes_mois` (
  `rc_year` int(11) NOT NULL,
  `rc_month` int(11) NOT NULL,
  `rc_montant` decimal(12,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `recettes_mois`
--

INSERT INTO `recettes_mois` (`rc_year`, `rc_month`, `rc_montant`) VALUES
(2018, 7, '0.00');

-- --------------------------------------------------------

--
-- Structure de la table `recettes_vendeurs`
--

CREATE TABLE `recettes_vendeurs` (
  `vd_id` int(11) NOT NULL,
  `rc_date` datetime NOT NULL,
  `rc_montant` decimal(12,2) DEFAULT NULL,
  `recette_dernieremod_dt` datetime NOT NULL,
  `recette_dernieremod_db_user` varchar(255) NOT NULL,
  `recette_dernieremod_user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déclencheurs `recettes_vendeurs`
--
DELIMITER $$
CREATE TRIGGER `recettes_historiques_delete` BEFORE DELETE ON `recettes_vendeurs` FOR EACH ROW BEGIN
INSERT INTO recettes_historique (
    vd_id,
    recette_derniere_mod_dt,
    rc_montant,
    recette_dernieremod_bd_user,
    recette_derniermod_user_id,
    evenement_histo)
    VALUES (
    OLD.vd_id,
    NOW(),
    OLD.rc_montant,
    CURRENT_USER(),
    @current_user_id,'DELETE');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `recettes_historiques_insert` BEFORE INSERT ON `recettes_vendeurs` FOR EACH ROW BEGIN
	SET NEW.rc_date = NOW();
	SET NEW.recette_dernieremod_dt = NEW.rc_date;
	SET NEW.recette_dernieremod_db_user = CURRENT_USER;
	SET NEW.recette_dernieremod_user_id = @current_user_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `recettes_historiques_update` BEFORE UPDATE ON `recettes_vendeurs` FOR EACH ROW BEGIN
INSERT INTO recettes_historique (
    vd_id,
    recette_derniere_mod_dt,
    rc_montant,
    recette_dernieremod_bd_user,
    recette_derniermod_user_id,
    evenement_histo)
    VALUES (
    OLD.vd_id,
    NOW(),
    OLD.rc_montant,
    CURRENT_USER(),
    @current_user_id,'UPDATE');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `recettes_vendeurs_delete` BEFORE DELETE ON `recettes_vendeurs` FOR EACH ROW BEGIN
UPDATE recettes_jour
SET rc_montant = rc_montant - OLD.rc_montant
WHERE rc_date = OLD.rc_date;
UPDATE recettes_mois
SET rc_montant = rc_montant - OLD.rc_montant
WHERE rc_year = YEAR( OLD.rc_date )
AND rc_month = MONTH( OLD.rc_date );
UPDATE recettes_vendeur_mois
SET rc_montant = rc_montant - OLD.rc_montant
WHERE rc_year = YEAR( OLD.rc_date )
AND rc_month = MONTH( OLD.rc_date )
AND vd_id = OLD.vd_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `recettes_vendeurs_insert` BEFORE INSERT ON `recettes_vendeurs` FOR EACH ROW BEGIN
	SET NEW.rc_date = NOW();
	INSERT INTO recettes_jour(rc_date, rc_montant) VALUES(NEW.rc_date, NEW.rc_montant) 
    ON DUPLICATE KEY UPDATE rc_montant = rc_montant + NEW.rc_montant;
    
    INSERT INTO recettes_mois(rc_year, rc_month, rc_montant) VALUES (YEAR( NEW.rc_date ), MONTH( NEW.rc_date ),NEW.rc_montant)
	ON DUPLICATE KEY UPDATE rc_montant = rc_montant + NEW.rc_montant;
    
    INSERT INTO recettes_vendeur_mois(rc_year, rc_month, vd_id, rc_montant) VALUES (YEAR( NEW.rc_date ), MONTH( NEW.rc_date ), NEW.vd_id, NEW.rc_montant)
	ON DUPLICATE KEY UPDATE rc_montant = rc_montant + NEW.rc_montant;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `recettes_vendeurs_update` BEFORE UPDATE ON `recettes_vendeurs` FOR EACH ROW BEGIN
UPDATE recettes_jour
SET rc_montant = rc_montant - OLD.rc_montant
WHERE rc_date = OLD.rc_date;
UPDATE recettes_jour
SET rc_montant = rc_montant + NEW.rc_montant
WHERE rc_date = NEW.rc_date;
UPDATE recettes_mois
SET rc_montant = rc_montant - OLD.rc_montant
WHERE rc_year = YEAR( OLD.rc_date )
AND rc_month = MONTH( OLD.rc_date );
UPDATE recettes_mois
SET rc_montant = rc_montant + NEW.rc_montant
WHERE rc_year = YEAR( NEW.rc_date )
AND rc_month = MONTH( NEW.rc_date );
UPDATE recettes_vendeur_mois
SET rc_montant = rc_montant - OLD.rc_montant
WHERE rc_year = YEAR( OLD.rc_date )
AND rc_month = MONTH( OLD.rc_date )
AND vd_id = OLD.vd_id;
UPDATE recettes_vendeur_mois
SET rc_montant = rc_montant + NEW.rc_montant
WHERE rc_year = YEAR( NEW.rc_date )
AND rc_month = MONTH( NEW.rc_date )
AND vd_id = NEW.vd_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `recettes_vendeur_mois`
--

CREATE TABLE `recettes_vendeur_mois` (
  `rc_year` int(11) NOT NULL,
  `rc_month` int(11) NOT NULL,
  `vd_id` int(11) NOT NULL,
  `rc_montant` decimal(12,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `recettes_vendeur_mois`
--

INSERT INTO `recettes_vendeur_mois` (`rc_year`, `rc_month`, `vd_id`, `rc_montant`) VALUES
(2018, 7, 1, '0.00'),
(2018, 7, 2, '0.00');

-- --------------------------------------------------------

--
-- Structure de la table `vendeurs`
--

CREATE TABLE `vendeurs` (
  `vd_id` int(11) NOT NULL,
  `vendeur_create_dt` datetime NOT NULL,
  `vd_nom` varchar(45) NOT NULL,
  `vd_prenom` varchar(20) NOT NULL,
  `vd_age` int(3) NOT NULL,
  `vd_adresse` varchar(45) NOT NULL,
  `salaire` int(11) NOT NULL,
  `mdp` varchar(120) NOT NULL,
  `vendeur_dernieremod_dt` datetime NOT NULL,
  `vendeur_dernieremod_db_user` varchar(255) NOT NULL,
  `vendeur_dernieremod_user_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `vendeurs`
--

INSERT INTO `vendeurs` (`vd_id`, `vendeur_create_dt`, `vd_nom`, `vd_prenom`, `vd_age`, `vd_adresse`, `salaire`, `mdp`, `vendeur_dernieremod_dt`, `vendeur_dernieremod_db_user`, `vendeur_dernieremod_user_id`) VALUES
(1, '2018-07-01 16:20:47', 'Manantsoa', 'Giovanna', 22, 'Ivory', 400000, '', '2018-07-01 16:20:47', 'root@localhost', NULL);

--
-- Déclencheurs `vendeurs`
--
DELIMITER $$
CREATE TRIGGER `vendeurs_delete` BEFORE DELETE ON `vendeurs` FOR EACH ROW BEGIN
	INSERT INTO vendeurs_historique (
    vd_id,
    vendeur_dernieremod_dt,
    vd_nom,
    vd_prenom,
    vd_age,
    vd_adresse,
    salaire,
    vendeur_dernieremod_bd_user,
    vendeur_dernieremod_user_id,
    evenement_histo)
    VALUES (
    OLD.vd_id,
    NOW(),
    OLD.vd_nom,
    OLD.vd_prenom,
    OLD.vd_age,
    OLD.vd_adresse,
    OLD.salaire,
    CURRENT_USER(),
    OLD.vendeur_dernieremod_user_id,
	'DELETE');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `vendeurs_insert` BEFORE INSERT ON `vendeurs` FOR EACH ROW BEGIN
	SET NEW.vendeur_create_dt = NOW();
	SET NEW.vendeur_dernieremod_dt = NEW.vendeur_create_dt;
	SET NEW.vendeur_dernieremod_db_user = CURRENT_USER;
	SET NEW.vendeur_dernieremod_user_id = @current_user_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `vendeurs_update` BEFORE UPDATE ON `vendeurs` FOR EACH ROW BEGIN
-- SET NEW.vendeur_dernieremod_dt = NOW();
-- SET NEW.vendeur_dernieremod_bd_user = CURRENT_USER();
INSERT INTO vendeurs_historique (
    vd_id,
    vendeur_dernieremod_dt,
    vd_nom,
    vd_prenom,
    vd_age,
    vd_adresse,
    salaire,
    vendeur_dernieremod_bd_user,
    vendeur_dernieremod_user_id,
    evenement_histo)
    VALUES (
    OLD.vd_id,
    NOW(),
    OLD.vd_nom,
    OLD.vd_prenom,
    OLD.vd_age,
    OLD.vd_adresse,
    OLD.salaire,
    CURRENT_USER(),
    OLD.vendeur_dernieremod_user_id,
	'UPDATE');
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `vendeurs_historique`
--

CREATE TABLE `vendeurs_historique` (
  `vd_id` int(11) NOT NULL,
  `vendeur_dernieremod_dt` datetime NOT NULL,
  `vd_nom` varchar(45) NOT NULL,
  `vd_prenom` varchar(20) NOT NULL,
  `vd_age` int(3) NOT NULL,
  `vd_adresse` varchar(45) NOT NULL,
  `salaire` int(11) NOT NULL,
  `vendeur_dernieremod_bd_user` varchar(255) NOT NULL,
  `vendeur_dernieremod_user_id` int(11) DEFAULT NULL,
  `evenement_histo` char(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `vendeurs_historique`
--

INSERT INTO `vendeurs_historique` (`vd_id`, `vendeur_dernieremod_dt`, `vd_nom`, `vd_prenom`, `vd_age`, `vd_adresse`, `salaire`, `vendeur_dernieremod_bd_user`, `vendeur_dernieremod_user_id`, `evenement_histo`) VALUES
(1, '2018-07-01 16:31:59', 'Manantsoa', 'Giovanni', 22, 'Tanambao', 400000, 'root@localhost', NULL, 'UPDATE'),
(1, '2018-07-13 12:43:21', 'Manantsoa', 'Giovanna', 22, 'Tanambao', 400000, 'root@localhost', NULL, 'UPDATE'),
(2, '2018-07-01 17:19:59', 'HellBell de Nico', 'Alvanna', 18, 'Tsaramandroso', 450000, 'root@localhost', NULL, 'DELETE');

--
-- Index pour les tables exportées
--

--
-- Index pour la table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`Id_adm`);

--
-- Index pour la table `recettes_historique`
--
ALTER TABLE `recettes_historique`
  ADD PRIMARY KEY (`vd_id`,`recette_derniere_mod_dt`);

--
-- Index pour la table `recettes_jour`
--
ALTER TABLE `recettes_jour`
  ADD PRIMARY KEY (`rc_date`);

--
-- Index pour la table `recettes_mois`
--
ALTER TABLE `recettes_mois`
  ADD PRIMARY KEY (`rc_year`,`rc_month`);

--
-- Index pour la table `recettes_vendeurs`
--
ALTER TABLE `recettes_vendeurs`
  ADD PRIMARY KEY (`vd_id`,`rc_date`),
  ADD KEY `rc_date` (`rc_date`,`vd_id`);

--
-- Index pour la table `recettes_vendeur_mois`
--
ALTER TABLE `recettes_vendeur_mois`
  ADD PRIMARY KEY (`rc_year`,`rc_month`,`vd_id`),
  ADD KEY `vd_id` (`vd_id`);

--
-- Index pour la table `vendeurs`
--
ALTER TABLE `vendeurs`
  ADD PRIMARY KEY (`vd_id`);

--
-- Index pour la table `vendeurs_historique`
--
ALTER TABLE `vendeurs_historique`
  ADD PRIMARY KEY (`vd_id`,`vendeur_dernieremod_dt`);

--
-- AUTO_INCREMENT pour les tables exportées
--

--
-- AUTO_INCREMENT pour la table `admin`
--
ALTER TABLE `admin`
  MODIFY `Id_adm` int(4) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT pour la table `vendeurs`
--
ALTER TABLE `vendeurs`
  MODIFY `vd_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
