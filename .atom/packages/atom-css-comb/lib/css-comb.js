'use babel';

import {CompositeDisposable} from 'atom';
import Comb from 'csscomb';
import path from 'path';

export default {
    config: {
        projectConfigs: {
            title: 'Use project config',
            description: 'Relative to the project directory. Example: `.csscomb.json` or `configs/.csscomb.json`. Leave blank if you want to use the following setting',
            default: '',
            type: 'string'
        },
        commonConfigs: {
            title: 'Use common config',
            description: 'Put here a full path to your config. Example: `/Users/jchouse/propjects/.csscomb.json`. Leave blank if you want to use the following setting',
            default: '',
            type: 'string'
        },
        readyMadeConfigs: {
            title: 'Ready made configs',
            description: 'Used when you do not specify a project or common file. The details below.',
            type: 'string',
            default: 'yandex',
            enum: ['yandex', 'csscomb', 'zen']
        },
        runOnSave: {
            title: 'Run on save',
            description: 'Format your files everytime you save',
            default: false,
            type: 'boolean'
        }
    },

    subscriptions: new CompositeDisposable(),

    getSettingsConfig() {
        var cssCombPackage = atom.packages.getLoadedPackage('atom-css-comb'),
            error,
            optionsFilePath,
            projectConfigs = atom.config.get('atom-css-comb.projectConfigs'),
            projectPath = atom.project.getPaths()[0],
            commonConfigs = atom.config.get('atom-css-comb.commonConfigs'),
            readyMadeConfigs = atom.config.get('atom-css-comb.readyMadeConfigs');

        if (projectConfigs) {
            optionsFilePath = path.join(projectPath, projectConfigs);
            try {
                return require(optionsFilePath);
            } catch (error) {
                return error;
            }
        } else if (commonConfigs) {
            try {
                return require(commonConfigs);
            } catch (error) {
                return error;
            }
        } else {
            return readyMadeConfigs || 'yandex';
        }
    },

    activate() {
        this.subscriptions.add(atom.commands.add('atom-workspace', {
          'css-comb:comb': () => this.comb()
        }));

        this.observeSave();
    },

    destroy() {
        this.subscriptions.dispose();
    },

    combFile(comb, syntax) {
        const text = this._getText();

        comb.processString(text, {syntax: syntax})
            .then(combed => atom.workspace.getActivePaneItem().setText(combed))
            .catch(error => atom.notifications.addError(error.message));
    },

    combText(comb, text) {
        var combed,
            syntax = this._getSytax(),
            activePane = atom.workspace.getActivePaneItem();

        comb.processString(text, {syntax: syntax})
            .then(result => activePane.setTextInBufferRange(activePane.getSelectedBufferRange(), result))
            .catch(error => atom.notifications.addError(error.message));
    },

    observeSave () {
        this.subscriptions.add(atom.workspace.observeTextEditors(editor => {
            this.subscriptions.add(editor.getBuffer().onWillSave(() => {
                var runOnSave = atom.config.get('atom-css-comb.runOnSave');
                var syntax = this._getSytax();
                if (!(syntax instanceof Error) && runOnSave) {
                    this.comb();
                }
            }));
        }));
    },

    _getSytax() {
        var syntax = atom.workspace.getActiveTextEditor().getGrammar().name.toLowerCase();

        if (['css', 'less', 'sass', 'scss'].includes(syntax)) {
            return syntax;
        } else if (['html', 'postcss'].includes(syntax)) {
            return 'css';
        } else {
            return new Error();
        }
    },

    _getSelectedText() {
        return atom.workspace.getActiveTextEditor().getSelectedText();
    },

    _getText() {
        return atom.workspace.getActiveTextEditor().getText();
    },

    comb() {
        var comb,
            config = this.getSettingsConfig(),
            selectedText = this._getSelectedText(),
            syntax = this._getSytax();

        if (config instanceof Error) {
            return atom.notifications.addError(config.message);
        } else if (syntax instanceof Error) {
            return atom.notifications.addError('Not supported syntax');
        } else {
            comb = new Comb(config);

            if (selectedText !== '') {
                this.combText(comb, selectedText, syntax);
            } else {
                let _name = atom.workspace.getActiveTextEditor().getGrammar().name;
                if (syntax === 'css' && _name === 'HTML') {
                    atom.notifications.addError('Please select the text for combing.');
                    return;
                }
                this.combFile(comb, syntax);
            }
        }
    }
};
