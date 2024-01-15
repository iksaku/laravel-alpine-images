<?php

class Tag {
  protected static $nextPriority = 200;
  public int $priority;

  public function __construct(
    public string $value,
    public ?string $prefix = null,
    public ?string $suffix = null,
  ) {
    $this->priority = Tag::$nextPriority--;
  }

  public function append(string $append): Tag {
    $this->value .= $append;

    return $this;
  }

  public function suffix(string $suffix): Tag {
    $this->suffix = $suffix;

    return $this;
  }

  public function __clone(): void {
    $this->priority = Tag::$nextPriority--;
  }

  public function __toString(): string {
    $properties = [
      'type' => 'raw',
      'value' => $this->value,
    ];

    if (!is_null($this->prefix) && trim($this->prefix) !== '') {
      $properties['prefix'] = $this->prefix;
    }
    
    if (!is_null($this->suffix) && trim($this->suffix) !== '') {
      $properties['suffix'] = $this->suffix;
    }

    if ($this->priority > 0) {
      $properties['priority'] = $this->priority;
    }

    return implode(',', array_map(
      fn (mixed $value, string $key) => "{$key}={$value}",
      $properties,
      array_keys($properties)
    ));
  }
}

function destructure_defaults(int $values, array $arr): array {
  return array_replace(
    array_fill(0, $values, ''),
    $arr
  );
}

function generate_semver_tags(string $semver): array {
  $parts = explode('.', $semver);

  if (count($parts) === 1) return $parts;

  return array_map(
    fn (int $length) => implode('.', array_slice($parts, 0, $length)),
    range(2, count($parts))
  );
}

[$php_version, $octane_runtime] = destructure_defaults(2, array_slice($argv, 1));

[$php_version, $php_variant] = destructure_defaults(2, explode(':', $php_version));

$tags = array_map(
  fn (string $semver) => new Tag(value: $semver),
  generate_semver_tags($php_version)
);

if (trim($php_variant) !== '') {
  if ($php_variant === 'cli') {
    $tags = array_merge(
      $tags,
      array_map(
        fn (Tag $tag) => (clone $tag)->append('-cli'),
        $tags
      )
    );
  } else {
    array_walk(
      $tags,
      fn (Tag $tag) => $tag->append("-{$php_variant}")
    );
  }
} else if (trim($octane_runtime) !== '') {
  if (!str_contains($octane_runtime, ':')) {
    throw new \RuntimeException('Octane Runtime is missing version.');
  }

  [$octane_runtime, $octane_runtime_version] = explode(':', $octane_runtime);

  if (trim($octane_runtime_version) === '') {
    throw new \RuntimeException('Octane Runtime is missing version.');
  }

  $tags = array_merge(
    ...array_map(
      fn (Tag $tag) => [
        $tag->append("-octane-{$octane_runtime}"),
        ...array_map(
          fn (string $semver) => (clone $tag)->append("-{$semver}"),
          generate_semver_tags($octane_runtime_version)
        )
      ],
      $tags
    )
  );
}

$tags = array_merge(
  $tags,
  array_map(
    fn (Tag $tag) => (clone $tag)->suffix('-{{sha}}'),
    $tags
  )
);

usort($tags, fn (Tag $a, Tag $b) => $b->priority <=> $a->priority);

echo join(PHP_EOL, $tags) . PHP_EOL;