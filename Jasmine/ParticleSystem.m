//
//  ParticleSystem.m
//  Jasmine
//
//  Created by Qiang Li on 12-10-3.
//  Copyright (c) 2012 Qiang Li. All rights reserved.
//

#import "ParticleSystem.h"
#import "util/random.h"

typedef struct _ParticleLinkedNode
{
    Particle *particle;
    struct _ParticleLinkedNode *prev;
    struct _ParticleLinkedNode *next;
} ParticleLinkedNode;

typedef struct _ParticleLinkedList
{
    ParticleLinkedNode *head;
    ParticleLinkedNode *tail;
} ParticleLinkedList;

static __inline__ void LinkedListRemoveNode(ParticleLinkedList *list, ParticleLinkedNode *node);
static __inline__ void LinkedListRemoveNode(ParticleLinkedList *list, ParticleLinkedNode *node)
{
    // check empty list
    if (list->head == NULL || list->tail == NULL)
        return;
    
    if (node->prev != NULL) {
        node->prev->next = node->next;
    } else { // node is list head
        list->head = node->next;
    }
    
    if (node->next != NULL) {
        node->next->prev = node->prev;
    } else { // node is list tail
        list->tail = node->prev;
    }
}

static __inline__ void LinkedListAddTail(ParticleLinkedList *list, ParticleLinkedNode *node);
static __inline__ void LinkedListAddTail(ParticleLinkedList *list, ParticleLinkedNode *node)
{
    if (list->head == NULL || list->tail == NULL) {
        node->prev = NULL;
        node->next = NULL;
        list->head = node;
        list->tail = node;
    } else {
        node->next = NULL;
        node->prev = list->tail;
        list->tail->next = node;
        list->tail = node;
    }
}

@interface ParticleSystem ()
{
    float _emitCounter;
    ParticleLinkedNode *_linkedNodes;
    
    ParticleLinkedList _order;
    ParticleLinkedList _idles;
}

- (void)updateWithInterval:(NSTimeInterval)dt;
- (void)allocParticlesWithCount:(NSUInteger)count;

- (void)initializeParticleLife:(Particle *)particle;
- (void)updateParticleLife:(Particle *)particle withTime:(NSTimeInterval)dt;

@end

@implementation ParticleSystem

- (id)initWithMaxCount:(NSUInteger)count
{
    return [self initWithMaxCount:count withEmitter:[ParticleEmitter new]];
}

- (id)initWithMaxCount:(NSUInteger)count withEmitter:(ParticleEmitter *)emitter
{
    self = [super init];
    if (self) {
        _maxCount = count;
        _emitter = emitter;
        _count = 0;
        _emitCounter = 0;
        [self allocParticlesWithCount:count];
        
        [self initializeDrawBuffer];
        
        [[Action constantlyUpdateActionWithDelegate:^(NSTimeInterval time) {
            [self updateWithInterval:time];
        }] play];
    }
    return self;
}

+ (size_t)propertySize
{
    return 0;
}

- (BOOL)isFull
{
    return _count == _maxCount;
}

- (void)allocParticlesWithCount:(NSUInteger)count
{
    size_t propertySize = [[self class] propertySize];
    // particles
    _particles = (Particle *)malloc(sizeof(Particle) * _maxCount);
    // properties
    if (propertySize != 0)
        _properties = (void *)malloc(propertySize * _maxCount);
    else
        _properties = NULL;
    // linked nodes
    _linkedNodes = (ParticleLinkedNode *)malloc(sizeof(ParticleLinkedNode) * _maxCount);
    
    for (uint i = 0; i < _maxCount; i++) {
        // bind property to particle
        if (propertySize != 0)
            _particles[i].property = _properties + i * propertySize;
        else
            _particles[i].property = NULL;
        // bind particle to linked node
        _linkedNodes[i].particle = &_particles[i];
        // set linked node's pointer
        if (i == 0)
            _linkedNodes[i].prev = NULL;
        else
            _linkedNodes[i].prev = &_linkedNodes[i - 1];
        if (i == _maxCount - 1)
            _linkedNodes[i].next = NULL;
        else
            _linkedNodes[i].next = &_linkedNodes[i + 1];
    }
    // set linked list head and tail
    _order.head = NULL;
    _order.tail = NULL;
    _idles.head = &_linkedNodes[0];
    _idles.tail = &_linkedNodes[_maxCount - 1];
}

- (void)dealloc
{
    free(_particles);
    if (_properties)
        free(_properties);
    free(_linkedNodes);
}

- (void)emit
{
    if (_count < _maxCount) {
        ParticleLinkedNode *head = _idles.head;
        // remove from idles
        LinkedListRemoveNode(&_idles, head);
        // initialize particle
        [self initializeParticleLife:head->particle];
        [self initializeParticle:head->particle];
        // add to tail
        LinkedListAddTail(&_order, head);
        
        _count++;
    } else if (_forceEmitWhenFull && _order.head != NULL) {
        ParticleLinkedNode *node = _order.head;
        // remove head
        LinkedListRemoveNode(&_order, node);
        // force generate with head paticle data
        [self initializeParticleLife:node->particle];
        [self initializeParticle:node->particle];
        // add to tail
        LinkedListAddTail(&_order, node);
    }
}

- (void)forceEmit
{
    if (_count < _maxCount) {
        ParticleLinkedNode *head = _idles.head;
        // remove from idles
        LinkedListRemoveNode(&_idles, head);
        // initialize particle
        [self initializeParticleLife:head->particle];
        [self initializeParticle:head->particle];
        // add to tail
        LinkedListAddTail(&_order, head);
        
        _count++;
    } else if (_order.head != NULL) {
        ParticleLinkedNode *node = _order.head;
        // remove head
        LinkedListRemoveNode(&_order, node);
        // force generate with head paticle data
        [self initializeParticleLife:node->particle];
        [self initializeParticle:node->particle];
        // add to tail
        LinkedListAddTail(&_order, node);
    }
}

- (void)updateWithInterval:(NSTimeInterval)dt
{
    if (dt == 0)
        return;
    float count = dt * self.emitPerSecond;
    _emitCounter += count;
    ParticleLinkedNode *node = _order.head;
    ParticleLinkedNode *next = NULL;
    while (node != NULL) {
        next = node->next;
        if (node->particle->life >= dt) {
            [self updateParticleLife:node->particle withTime:dt];
            [self updateParticle:node->particle withInterval:dt];
        // going to remove
        } else if (node->particle->life > 0.f) {
            // delete node in order
            node->particle->life = 0;
            LinkedListRemoveNode(&_order, node);
            LinkedListAddTail(&_idles, node);
            _count--;
        }
        node = next;
    }
    while (_autoEmit && _emitCounter >= 1.f) {
        [self emit];
        _emitCounter -= 1.f;
    }
    // iterate order list
    ParticleLinkedNode *iterater = _order.head;
    NSUInteger index = 0;
    while (iterater != NULL) {
        [self updateDrawBuffer:iterater->particle withIndex:index];
        iterater = iterater->next;
        index++;
    }
}

- (void)setAutoEmit:(BOOL)autoEmit
{
    if (!autoEmit)
        _emitCounter = 0;
    _autoEmit = autoEmit;
}

- (void)initializeParticleLife:(Particle *)particle
{
    particle->maxLife = (RANDOM_MINUS1_1 * self.maxLifeVariety + 1) * self.maxLife;
    particle->life = particle->maxLife;
}

- (void)updateParticleLife:(Particle *)particle withTime:(NSTimeInterval)dt
{
    particle->life -= dt;
}

// override
- (void)initializeParticle:(Particle *)particle
{
}

// override
- (void)updateParticle:(Particle *)particle withInterval:(NSTimeInterval)dt
{
}

// override
- (void)updateDrawBuffer:(Particle *)particle withIndex:(NSUInteger)index
{
}

// override
- (void)initializeDrawBuffer
{
}

@end
