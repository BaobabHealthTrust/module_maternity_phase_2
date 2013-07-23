ALTER table user_property MODIFY column property_value text;

INSERT INTO `patient_identifier_type` (`name`, `description`, `creator`, `date_created`, uuid) VALUES ('Serial Number', 'Birth Registration Serial Number', 1, '2012-08-29 00:00:00', UUID());

INSERT INTO `person_attribute_type` (`name`, `description`, `creator`, `date_created`, uuid) VALUES ('Provider Title', 'Birth Registration field', 1, '2012-08-09 00:00:00', UUID());

INSERT INTO `person_attribute_type` (`name`, `description`, `creator`, `date_created`, uuid) VALUES ('Hospital Date', 'Birth Registration field', 1, '2012-08-09 00:00:00', UUID());

INSERT INTO `person_attribute_type` (`name`, `description`, `creator`, `date_created`, uuid) VALUES ('Provider Name', 'Birth Registration field', 1, '2012-08-09 00:00:00', UUID());




