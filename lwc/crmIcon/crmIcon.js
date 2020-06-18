import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

import FONT_AWESOME from '@salesforce/resourceUrl/newFontAwesome';
import ICCU_ICON_FONT from '@salesforce/resourceUrl/iccuIconFont';

/**
 * Supports several types of icons (mutually exclusive) that require the following attributes:
 *
 *      Custom Font:  custom-icon-classes
 *      Font Awesome:  fa-icon-classes
 *      SVG:  svg-icon
 *
 * It supports a variety of fixed font colors (see CSS and/or defaultTokens).
 *
 * The size supports the following values: small, medium, large.
 */
export default class CrmLwcFontAwesomeIcon extends LightningElement {

    @api alternativeText = null;
    @api color = null;
    @api backgroundColor = null;
    @api customIconClass = null;
    @api faIconClass = null;
    @api size = 'large';
    @api svgIcon = null;

    connectedCallback() {
        // Ensure that only one icon is provided and load any necessary styles.
        if (this.hasCustomIcon()) {
            loadStyle(this, ICCU_ICON_FONT + '/style.css');
            this.faIconClass = null;
            this.svgIcon = null;
        } else if (this.hasFontAwesomeIcon()) {
            loadStyle(this, FONT_AWESOME + '/fontawesome-free-5.8.2-web/css/all.css');
            this.customIconClass = null;
            this.svgIcon = null;
        } else if (this.hasSvgIcon()) {
            this.customIconClass = null;
            this.faIconClass = null;
        }

        // Ensure the colors are all lower case for styling reasons.
        this.backgroundColor = this.backgroundColor ? this.backgroundColor.toLowerCase() : null;
        this.color = this.color ? this.color.toLowerCase() : 'gray';

        // If no icon was provided, default to an error icon so that something is displayed.
        if (!this.hasCustomIcon() && !this.hasFontAwesomeIcon() && !this.hasSvgIcon()) {
            this.faIconClass = 'fa-exclamation';
            this.color = 'white';
            this.backgroundColor = 'red';
        }
    }

    hasCustomIcon() {
        return this.customIconClass && this.customIconClass !== '';
    }

    hasFontAwesomeIcon() {
        return this.faIconClass && this.faIconClass !== '';
    }

    hasSvgIcon() {
        return this.svgIcon && this.svgIcon !== '';
    }

    get iconBackgroundClasses() {
        let classes = this.size;
        if (this.backgroundColor && this.backgroundColor !== '') {
            classes = classes + ' ' + this.backgroundColor;
        } else {
            classes += ' no-background';
        }
        return classes;
    }

    get iconClasses() {
        let classes = 'icon ' + (this.hasFontAwesomeIcon() ? 'fas ' + this.faIconClass : this.customIconClass) + ' ' + this.color;
        return classes;
    }

    get showFontIcon() {
        return this.hasCustomIcon() || this.hasFontAwesomeIcon();
    }

    get showSvgIcon() {
        return this.hasSvgIcon();
    }

}