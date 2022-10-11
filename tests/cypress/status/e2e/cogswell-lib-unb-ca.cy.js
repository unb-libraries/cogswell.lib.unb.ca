const host = 'https://cogswell.lib.unb.ca'
describe('Fred Cogswell', {baseUrl: host, groups: ['sites']}, () => {

  context('Front page', {baseUrl: host}, () => {
    beforeEach(() => {
      cy.visit('/')
      cy.title()
        .should('contain', 'Fred Cogswell')
    })

    specify('Search for "Borealis" should find 10+ results', () => {
      cy.get('#block-cogswell-theme-search form').within(() => {
        cy.get('input#edit-keys')
          .type('Borealis')
      }).submit()
      cy.url()
        .should('match', /\/search\/node/)
      cy.get('ol li')
        .should('have.lengthOf.at.least', 10)
    })

    specify('"Embeded Issuu" iFrame should be visible', () => {
      cy.getEmbededIssuu().within(() => {
        cy.get('.reader')
          .should('be.visible')
      })
    });
  })

})
