import * as assert from 'assert';
import * as fs from 'fs';
import * as path from 'path';

const grammar = JSON.parse(
    fs.readFileSync(path.join(__dirname, '../../syntaxes/systemverilog.tmLanguage.json'), 'utf8')
);
const forkControl = grammar.repository['sv-fork-control'];
const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, '../../package.json'), 'utf8'));

suite('Syntax Grammar Tests', () => {
    test('ordinary disable statements use the control keyword scope', () => {
        const control = grammar.repository['sv-control'];
        assert.strictEqual(control.captures['1'].name, 'keyword.control.systemverilog');
        for (const source of ['disable worker;', '    disable top.worker;', 'disable fork_worker;']) {
            assert.strictEqual(new RegExp(control.match).exec(source)[1], 'disable');
            assert.strictEqual(new RegExp(grammar.repository.keywords.patterns[1].match).exec(source), null);
            assert.strictEqual(new RegExp(forkControl.match).exec(source), null);
        }
    });

    test('fork control statements take precedence over individual keywords and block openers', () => {
        const patterns = grammar.repository.keywords.patterns;
        assert.strictEqual(patterns[0].include, '#sv-fork-control');
        assert.strictEqual(forkControl.name, 'meta.fork-control.systemverilog');
        assert.strictEqual(forkControl.captures['1'].name, 'keyword.control.systemverilog');
        assert.strictEqual(forkControl.captures['2'].name, 'keyword.control.systemverilog');
    });

    test('fork control statements are excluded from bracket matching in every SystemVerilog grammar', () => {
        const contributions = manifest.contributes.grammars.filter((entry) => entry.scopeName === grammar.scopeName);
        assert.ok(contributions.length > 0);
        for (const contribution of contributions) {
            assert.ok(contribution.unbalancedBracketScopes.includes(forkControl.name));
        }
        assert.notStrictEqual(grammar.repository['sv-control-begin'].name, forkControl.name);
    });

    test('matches wait fork and disable fork with whitespace between keywords', () => {
        for (const keyword of ['wait', 'disable']) {
            for (const whitespace of [' ', '\t', '\n', '  \t ']) {
                const match = new RegExp(forkControl.match).exec(`${keyword}${whitespace}fork;`);
                assert.ok(match);
                assert.strictEqual(match[1], keyword);
                assert.strictEqual(match[2], 'fork');
            }
        }
    });

    test('indented fork control statements match before the generic control rule', () => {
        for (const keyword of ['wait', 'disable']) {
            const source = `    ${keyword} fork;`;
            const match = new RegExp(forkControl.match).exec(source);
            assert.ok(match);
            assert.strictEqual(match.index, 0);
            assert.strictEqual(match[1], keyword);
            assert.strictEqual(match[2], 'fork');
        }
    });

    test('preserves ordinary waits, named disables, fork blocks, and identifier boundaries', () => {
        for (const source of [
            'wait (ready);',
            'disable worker;',
            'fork : worker',
            'await fork;',
            'wait forked;',
            'disable fork_worker;'
        ]) {
            assert.strictEqual(new RegExp(forkControl.match).exec(source), null);
        }
        assert.ok(new RegExp(grammar.repository['sv-control-begin'].match).test('fork : worker'));
    });
});
