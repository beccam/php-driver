@php-version-5.4 @skip-travisci
Feature: Persistent Sessions

  PHP Driver sessions can persist

  Background:
    Given a running Cassandra cluster
    And a file named "status.php" with:
      """php
      <?php

      echo phpinfo();
      """

  Scenario: No sessions have been created
    When I go to "/status.php"
    Then I should see:
      | Persistent Clusters | 0 |
      | Persistent Sessions | 0 |

  Scenario: A single session is re-used for all requests
    Given a file named "connect.php" with:
      """php
      <?php

      $cluster = Cassandra::cluster()
                         ->withContactPoints('127.0.0.1')
                         ->withPersistentSessions(true)
                         ->build();
      $session = $cluster->connect();
      """
    When I go to "/connect.php" 5 times
    When I go to "/status.php"
    Then I should see:
      | Persistent Clusters | 1 |
      | Persistent Sessions | 1 |

  Scenario: Non-persistent sessions are recreated for each request
    Given a file named "connect.php" with:
      """php
      <?php

      $cluster = Cassandra::cluster()
                         ->withContactPoints('127.0.0.1')
                         ->withPersistentSessions(false)
                         ->build();
      $session = $cluster->connect();
      """
    When I go to "/connect.php"
    When I go to "/status.php"
    Then I should see:
      | Persistent Clusters | 0 |
      | Persistent Sessions | 0 |
