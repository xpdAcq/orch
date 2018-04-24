# Registry of installers
installers = ${...}.get('INSTALLERS',
                        {'conda': 'conda install', 'pip': 'pip install'})

# Order to run installers (conda installing pip, then pip installing things)
installer_order = ${...}.get('INSTALLERS_ORDER', ['conda', 'pip'])

# Read the precedence configuration (usually from CI)
precedence = ${...}.get('PRECEDENCE', ['default'])
# Bash hack, bash doesn't support array values, so we split strings
if isinstance(precedence, str):
    precedence = precedence.split()


def run(config):

    deps = {}
    # Go through the keys in precedence order
    for p in precedence:
        for k, v in config.items():
            vg = v.get(p)
            if vg:
                deps[k] = vg
    print(deps)

    installs = {}
    for k, v in deps.items():
        installer = list(v.keys())[0]
        if installer in installs:
            installs[installer].append(v[installer])
        else:
            installs[installer] = [v[installer]]

    print(installs)

    # execute the installs for each
    for i in installer_order:
        if i in installers:
            x = (installers[i] + ' ' + ' '.join(installs[i])).split()
            print(x)
            @(x)
        else:
            raise KeyError('That installer is not currently in the '
                           'installation registry. Please add it by '
                           'updating the $INSTALLERS env var.')