<?php

namespace Drupal\cogs_core\Plugin\Menu;

use Drupal\Core\Menu\MenuLinkDefault;
use Drupal\Core\Url;

/**
 * Provides a code-driven menu link for mailto URIs with a subject line.
 */
class MailtoMenuLink extends MenuLinkDefault {

  /**
   * {@inheritdoc}
   */
  public function getUrlObject($title_attribute = TRUE) {
    $email = 'tremblay@stu.ca';
    $subject = 'Fred Cogswell: The Many-Dimensioned Self';
    
    // rawurlencode converts spaces to %20 instead of + signs, which mail clients prefer
    $uri = 'mailto:' . $email . '?subject=' . rawurlencode($subject);
    
    return Url::fromUri($uri);
  }

}
